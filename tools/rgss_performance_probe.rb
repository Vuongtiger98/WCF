#==============================================================================
# WCF performance probe - RGSS3 / Ruby 1.9.2, development use only.
# Load with an event Script command, then capture a bounded sample:
#   load 'tools/rgss_performance_probe.rb'
#   WCFPerformanceProbe.start(600)
# No hotkeys, event changes, save changes, or hooks before start is called.
#==============================================================================
module WCFPerformanceProbe
  class << self
    attr_reader :last_report_path

    def running?
      @running == true
    end

    def start(frames = 600)
      stop if running?
      install unless @installed
      @frames = 0
      @limit = [[frames.to_i, 1].max, 36000].min
      @stats = {}
      @frame_times = []
      @started_at = Time.now.to_f
      @last_present_at = @started_at
      @running = true
      true
    end

    def measure(label)
      began = Time.now.to_f
      yield
    ensure
      if running?
        elapsed = [(Time.now.to_f - began) * 1000.0, 0.0].max
        map_id = $game_map ? $game_map.map_id : 0
        key = [map_id, label]
        entry = (@stats[key] ||= [0, 0.0, 0.0])
        entry[0] += 1
        entry[1] += elapsed
        entry[2] = elapsed if elapsed > entry[2]
      end
    end

    def tick
      return unless running?
      now = Time.now.to_f
      @frame_times << [(now - @last_present_at) * 1000.0, 0.0].max
      @last_present_at = now
      @frames += 1
      stop if @frames >= @limit
    end

    def stop
      return unless running?
      @running = false
      elapsed = [Time.now.to_f - @started_at, 0.001].max
      sorted = @frame_times.sort
      p95 = sorted.empty? ? 0.0 : sorted[[(sorted.size * 0.95).ceil - 1, 0].max]
      lines = [
        'WCF RGSS3 performance capture',
        "frames=#{@frames} elapsed_seconds=#{elapsed.round(3)} present_fps=#{(@frames / elapsed).round(2)}",
        "target_fps=#{Graphics.frame_rate} frame_p95_ms=#{p95.round(3)}",
        'Component times are inclusive: nested measurements must not be added together.',
        'Rendering, Graphics.update waiting, and OS scheduling also affect frame time.',
        'map_id,component,calls,total_ms,mean_ms,max_ms'
      ]
      @stats.sort_by { |key, entry| -entry[1] }.each do |key, entry|
        lines << [key[0], key[1], entry[0], entry[1].round(3),
          (entry[1] / entry[0]).round(3), entry[2].round(3)].join(',')
      end
      Dir.mkdir('Save') unless File.directory?('Save')
      stamp = Time.now.strftime('%Y%m%d_%H%M%S')
      path = "Save/Performance_#{stamp}.txt"
      suffix = 1
      while File.exist?(path)
        path = "Save/Performance_#{stamp}_#{suffix}.txt"
        suffix += 1
      end
      File.open(path, 'wb') { |file| file.write(lines.join("\r\n") + "\r\n") }
      @last_report_path = path
      path
    end

    def wrap(owner, name, label)
      return unless owner.method_defined?(name) || owner.private_method_defined?(name)
      original = ('wcf_perf_original_' + name.to_s).to_sym
      return if owner.method_defined?(original) || owner.private_method_defined?(original)
      was_private = owner.private_method_defined?(name)
      owner.class_eval do
        alias_method original, name
        define_method(name) do |*args, &block|
          if WCFPerformanceProbe.running?
            WCFPerformanceProbe.measure(label) { send(original, *args, &block) }
          else
            send(original, *args, &block)
          end
        end
        private name if was_private
      end
    end

    def install
      @installed = true
      wrap(Game_Map, :update_events, 'events') if defined?(Game_Map)
      wrap(Spriteset_Map, :update, 'map_sprites_total') if defined?(Spriteset_Map)
      wrap(Spriteset_Map, :update_characters, 'characters') if defined?(Spriteset_Map)
      wrap(Spriteset_Map, :update_layers, 'layers') if defined?(Spriteset_Map)
      wrap(Spriteset_Map, :update_weather_ex, 'weather_ex') if defined?(Spriteset_Map)
      wrap(Shadow, :draw, 'kul_total') if defined?(Shadow)
      wrap(Light_Source, :draw_shadow, 'kul_shadow_mask') if defined?(Light_Source)
      wrap(Spriteset_Map_Effects, :update, 'map_effects') if defined?(Spriteset_Map_Effects)
      wrap(Scene_Menu, :update, 'phone_menu_total') if defined?(Scene_Menu)
      wrap(Scene_Menu, :draw_main_panel, 'phone_panel_draw') if defined?(Scene_Menu)
      graphics_class = class << Graphics; self; end
      graphics_class.class_eval do
        alias_method :wcf_perf_original_graphics_update, :update
        def update(*args, &block)
          result = wcf_perf_original_graphics_update(*args, &block)
          WCFPerformanceProbe.tick if WCFPerformanceProbe.running?
          result
        end
      end
    end
  end
end
