(() => {
  'use strict';

  const D = window.WCF_CONTENT;
  const OVERRIDES = window.WCF_FRAMES || {};
  const FACES = window.WCF_FACES || [];
  const DIALOGUES = window.WCF_DIALOGUE_DATA || { items: [], stats: {} };
  const DIALOGUES_BY_MAP = DIALOGUES.items.reduce((result, item) => {
    if (item.mapId != null) (result[String(item.mapId)] ||= []).push(...(item.frames || []));
    return result;
  }, {});
  const STORAGE_KEY = 'wcf_qa_offline_v3';
  const OLD_STORAGE_KEY = 'wcf_qa_offline_v2';
  const UPDATE_BACKUP_PREFIX = 'wcf_qa_offline_backup_before_content_v';
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const esc = (value = '') => String(value).replace(/[&<>"']/g, char => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[char]));
  const now = () => new Date().toISOString();
  const types = { route: D.routes, scene: D.scenes, map: D.maps, minigame: D.minigames, dialogue: DIALOGUES.items };
  const typeLabel = { route: 'Route', scene: 'Scene', map: 'Map tương tác', minigame: 'Minigame', dialogue: 'Toàn bộ thoại' };
  const statusLabels = {
    untested: 'Chưa test', testing: 'Đang test', pass: 'Hoàn tất', bug: 'Có báo cáo'
  };

  function blankState() {
    return { version: 3, contentVersion: D.meta.version, frames: {}, positions: {}, issues: [], proposals: [], lastVisited: null, updatedAt: now() };
  }

  function preserveBeforeContentUpdate(raw, value) {
    const previousVersion = Number(value?.contentVersion || 2);
    if (previousVersion === Number(D.meta.version)) return;
    const backupKey = `${UPDATE_BACKUP_PREFIX}${previousVersion}`;
    try {
      if (!localStorage.getItem(backupKey)) localStorage.setItem(backupKey, raw);
    } catch (_) {
      // Thiếu dung lượng backup không được phép làm mất state chính đang đọc.
    }
  }

  function load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const value = JSON.parse(raw);
        preserveBeforeContentUpdate(raw, value);
        return normalizeState(value);
      }
      const oldRaw = localStorage.getItem(OLD_STORAGE_KEY);
      if (oldRaw) {
        const value = JSON.parse(oldRaw);
        preserveBeforeContentUpdate(oldRaw, value);
        return migrateV2(value);
      }
    } catch (_) {}
    return blankState();
  }

  function normalizeState(value) {
    return {
      ...blankState(), ...value, version: 3, contentVersion: D.meta.version,
      frames: value.frames || {}, positions: value.positions || {},
      issues: value.issues || [], proposals: value.proposals || []
    };
  }

  function migrateV2(old) {
    const migrated = normalizeState(old);
    Object.entries(old.checks || {}).forEach(([key, value]) => {
      if (value.status === 'pass') migrated.frames[`check:${key}`] = { ok: true, updatedAt: value.updatedAt || now() };
    });
    migrated.issues = (old.issues || []).map(issue => ({ ...issue, frameId: issue.frameId || issue.checkKey || 'legacy' }));
    return migrated;
  }

  let state = load();

  function save() {
    state.updatedAt = now();
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
      $('#saveIndicator').textContent = 'Đã lưu';
    } catch (_) {
      $('#saveIndicator').textContent = 'Không lưu được';
    }
    updateNavCounts();
  }

  function findItem(type, id) {
    return types[type]?.find(item => item.id === id);
  }

  function allItems() {
    return Object.entries(types).flatMap(([type, items]) => items.map(item => ({ ...item, _type: type })));
  }

  function itemKey(type, item) {
    return `${type}:${item.id}`;
  }

  function frameKey(type, item, frame) {
    return `${itemKey(type, item)}:${frame.id}`;
  }

  function itemFrames(type, item) {
    if (Array.isArray(item.frames) && item.frames.length) return item.frames;
    const override = OVERRIDES[itemKey(type, item)];
    const setup = {
      id: 'setup', kind: 'description', title: 'Đi tới điểm bắt đầu',
      text: [item.start ? `Bắt đầu tại ${item.start}.` : '', ...(item.steps || [])].filter(Boolean).join('\n'),
      source: `${item.id} · setup`
    };
    const checks = (item.checkKeys || []).map((key, index) => {
      const check = D.checks[key] || {};
      return {
        id: `check-${index + 1}-${key.replace(/[^a-z0-9]+/gi, '-')}`,
        kind: 'description', title: check.action || key,
        text: check.result || 'Quan sát và xác nhận diễn biến này trong game.',
        source: key, checkKey: key
      };
    });
    const baseFrames = override?.length ? [...override] : [setup, ...checks];
    if (type !== 'map' && type !== 'scene') return baseFrames;

    const mapMatch = `${item.id || ''} ${item.title || ''}`.match(/map\s*0*(\d+)/i);
    if (!mapMatch) return baseFrames;
    const extracted = DIALOGUES_BY_MAP[String(Number(mapMatch[1]))] || [];
    return [...baseFrames, ...extracted];
  }

  function frameIsOk(type, item, frame) {
    return Boolean(state.frames[frameKey(type, item, frame)]?.ok || (frame.checkKey && state.frames[`check:${frame.checkKey}`]?.ok));
  }

  function itemIssues(type, item) {
    return state.issues.filter(issue => issue.type === type && issue.itemId === item.id);
  }

  function itemStatus(type, item) {
    const frames = itemFrames(type, item);
    if (itemIssues(type, item).length) return 'bug';
    const done = frames.filter(frame => frameIsOk(type, item, frame)).length;
    if (done === frames.length && frames.length) return 'pass';
    if (done || state.positions[itemKey(type, item)] > 0) return 'testing';
    return 'untested';
  }

  function completion(type, items) {
    const done = items.filter(item => itemStatus(type, item) === 'pass').length;
    return { done, total: items.length, pct: items.length ? Math.round(done / items.length * 100) : 0 };
  }

  function itemProgress(type, item) {
    const frames = itemFrames(type, item);
    const done = frames.filter(frame => frameIsOk(type, item, frame)).length;
    return { done, total: frames.length, pct: frames.length ? Math.round(done / frames.length * 100) : 0 };
  }

  function statusPill(status) {
    return `<span class="status-pill ${status}">${esc(statusLabels[status])}</span>`;
  }

  function itemHref(type, id) {
    return `#item/${type}/${encodeURIComponent(id)}`;
  }

  function searchBlob(item) {
    const checks = (item.checkKeys || []).map(key => {
      const check = D.checks[key] || {};
      return `${check.action || ''} ${check.result || ''}`;
    }).join(' ');
    const frameText = (item.frames || []).map(frame => `${frame.speaker || ''} ${frame.text || ''}`).join(' ');
    return [item.title, item.group, item.start, item.end, item.recipient, item.gift, item.startArea, item.search, ...(item.steps || []), checks, frameText].join(' ').toLowerCase();
  }

  function updateNavCounts() {
    if ($('#navRoutesCount')) $('#navRoutesCount').textContent = `${completion('route', D.routes).done}/${D.routes.length}`;
    const count = state.issues.length + state.proposals.length;
    if ($('#navIssuesCount')) $('#navIssuesCount').textContent = count ? String(count) : '';
  }

  function pageHead(title, subtitle = '', actions = '') {
    return `<div class="page-head"><div><h1>${esc(title)}</h1>${subtitle ? `<p>${esc(subtitle)}</p>` : ''}</div>${actions ? `<div class="actions">${actions}</div>` : ''}</div>`;
  }

  function progressHtml(progress) {
    return `<div class="progress-row"><span>${progress.done}/${progress.total} khung OK</span><span>${progress.pct}%</span></div><div class="progress"><span style="width:${progress.pct}%"></span></div>`;
  }

  function route() {
    const hash = (location.hash || '#dashboard').slice(1);
    $$('.nav a').forEach(link => link.classList.toggle('active', Boolean(link.dataset.nav && hash.startsWith(link.dataset.nav))));
    if (hash === 'dashboard') return renderDashboard();
    if (hash === 'routes') return renderList('route');
    if (hash === 'scenes') return renderList('scene');
    if (hash === 'maps') return renderList('map');
    if (hash === 'minigames') return renderList('minigame');
    if (hash === 'dialogues') return renderList('dialogue');
    if (hash === 'issues') return renderResults();
    if (hash.startsWith('item/')) {
      const [, type, id] = hash.split('/');
      return renderDetail(type, decodeURIComponent(id || ''));
    }
    renderDashboard();
  }

  function renderDashboard() {
    const recent = state.lastVisited && findItem(state.lastVisited.type, state.lastVisited.id);
    const cards = Object.entries(types).map(([type, items]) => {
      const progress = completion(type, items);
      return `<a class="card stat-card hover" href="#${type}s" style="text-decoration:none"><div><div class="stat-label">${esc(typeLabel[type])}</div><div class="stat-value">${progress.done}</div><div class="stat-sub">${progress.total} mục trong phạm vi test</div></div>${progressHtml(progress)}</a>`;
    }).join('');
    $('#content').innerHTML = pageHead('Tổng quan', 'Mỗi lần chỉ cần đối chiếu một khung trong game') + `
      <div class="grid cols-4">${cards}</div>
      <div class="grid cols-2" style="margin-top:14px">
        <div class="card"><div class="stat-label">Tiếp tục lần test gần nhất</div>
          ${recent ? `<div class="resume-title">${esc(recent.title)}</div><div class="muted small">${esc(typeLabel[state.lastVisited.type])}</div><a class="btn primary resume-btn" href="${itemHref(state.lastVisited.type, recent.id)}">Mở lại</a>` : '<div class="empty compact">Chưa mở mục nào.</div>'}
        </div>
        <a class="card hover result-summary" href="#issues"><div class="stat-label">Kết quả gửi đi</div><div class="stat-value">${state.issues.length + state.proposals.length}</div><div class="stat-sub">${state.issues.length} lỗi · ${state.proposals.length} đề xuất</div></a>
      </div>`;
  }

  function renderList(type) {
    const items = types[type];
    const groups = [...new Set(items.map(item => item.group))];
    const subtitle = type === 'dialogue'
      ? `${items.length} event/page · ${DIALOGUES.stats?.totalFrames || 0} khung trích trực tiếp từ game`
      : `${items.length} mục`;
    $('#content').innerHTML = pageHead(typeLabel[type], subtitle) + `
      <div class="toolbar">
        <input id="listSearch" placeholder="Tìm trong ${esc(typeLabel[type].toLowerCase())}...">
        <select id="groupFilter"><option value="">Tất cả nhóm</option>${groups.map(group => `<option value="${esc(group)}">${esc(group)}</option>`).join('')}</select>
        <select id="statusFilter"><option value="">Tất cả trạng thái</option>${Object.entries(statusLabels).map(([key, label]) => `<option value="${key}">${esc(label)}</option>`).join('')}</select>
      </div><div id="listGrid" class="item-grid"></div>`;
    const apply = () => {
      const query = $('#listSearch').value.trim().toLowerCase();
      const group = $('#groupFilter').value;
      const status = $('#statusFilter').value;
      const filtered = items.filter(item => (!query || searchBlob(item).includes(query)) && (!group || item.group === group) && (!status || itemStatus(type, item) === status));
      $('#listGrid').innerHTML = filtered.length ? filtered.map(item => itemCard(type, item)).join('') : '<div class="empty">Không có kết quả.</div>';
    };
    $$('#content .toolbar input,#content .toolbar select').forEach(element => element.addEventListener('input', apply));
    apply();
  }

  function itemCard(type, item) {
    const progress = itemProgress(type, item);
    const tags = [item.group, item.recipient, item.gift].filter(Boolean).slice(0, 3);
    return `<a class="item-card" href="${itemHref(type, item.id)}"><div class="item-card-head"><div class="item-title">${esc(item.title)}</div>${statusPill(itemStatus(type, item))}</div><div class="tags">${tags.map(tag => `<span class="tag">${esc(tag)}</span>`).join('')}</div>${progressHtml(progress)}</a>`;
  }

  function renderDetail(type, id) {
    const item = findItem(type, id);
    if (!item) return renderDashboard();
    state.lastVisited = { type, id };
    const frames = itemFrames(type, item);
    const key = itemKey(type, item);
    let index = Number(state.positions[key] || 0);
    index = Math.max(0, Math.min(index, frames.length - 1));
    state.positions[key] = index;
    save();
    const frame = frames[index];
    const ok = frameIsOk(type, item, frame);
    const progress = itemProgress(type, item);
    $('#content').innerHTML = `
      <div class="test-player">
        <div class="breadcrumbs"><a href="#${type}s">${esc(typeLabel[type])}</a> / ${esc(item.group)}</div>
        <div class="player-head"><div><div class="player-title">${esc(item.title)}</div><div class="player-position">Khung ${index + 1} / ${frames.length} · ${frame.kind === 'dialogue' ? 'Thoại' : 'Mô tả'}</div></div>${statusPill(itemStatus(type, item))}</div>
        ${progressHtml(progress)}
        <div class="single-frame ${frame.kind} ${ok ? 'is-ok' : ''}">
          <div class="frame-ok-mark">✓ Đã OK</div>
          ${renderFrame(frame)}
          <div class="frame-reference">Mã để sửa: <code>${esc(type)} / ${esc(item.id)} / ${esc(frame.id)}</code>${frame.source ? ` · Nguồn: ${esc(frame.source)}` : ''}</div>
        </div>
        <div class="player-actions">
          <button class="btn ghost" id="backFrame" ${index === 0 ? 'disabled' : ''}>← Quay lại</button>
          <button class="btn danger" id="reportBug">Báo lỗi</button>
          <button class="btn suggestion" id="suggestChange">Đề xuất</button>
          <button class="btn ok ${ok ? 'active' : ''}" id="markOk">${ok ? '✓ OK' : 'OK'}</button>
          <button class="btn primary" id="nextFrame">${index === frames.length - 1 ? 'Hoàn thành' : 'Tiếp tục →'}</button>
        </div>
      </div>`;
    $('#backFrame').onclick = () => moveTo(type, item, index - 1);
    $('#nextFrame').onclick = () => index === frames.length - 1 ? location.hash = `${type}s` : moveTo(type, item, index + 1);
    $('#markOk').onclick = () => {
      state.frames[frameKey(type, item, frame)] = { ok: true, updatedAt: now() };
      save();
      renderDetail(type, item.id);
    };
    $('#reportBug').onclick = () => openIssueModal(type, item, frame);
    $('#suggestChange').onclick = () => openSuggestionModal(type, item, frame);
  }

  function moveTo(type, item, index) {
    state.positions[itemKey(type, item)] = index;
    save();
    renderDetail(type, item.id);
  }

  function renderFrame(frame) {
    if (frame.kind === 'dialogue') {
      const validation = dialogueValidation(frame.text || '', Boolean(frame.face));
      const validationText = validation.valid
        ? `✓ ${validation.lines.length}/4 dòng · ${validation.limit} ký tự/dòng${validation.hardLimit > validation.limit ? ` (cho phép tối đa ${validation.hardLimit})` : ''}`
        : `⚠ Nội dung hiện tại vượt ${validation.hardLimit} ký tự/dòng hoặc 4 dòng — bấm Đề xuất để sửa`;
      return `<div class="rpg-message">
        ${frame.face ? facePortrait(frame.face, frame.faceIndex || 0) : ''}
        <div class="dialogue-copy"><div class="dialogue-meta"><span class="speaker">${esc(frame.speaker || 'Không ghi người nói')}</span>${frame.pop ? '<span class="pop-badge">✓ Pop message</span>' : '<span class="normal-badge">Thoại thường</span>'}</div><div class="dialogue-text">${esc(frame.text)}</div></div>
      </div><div class="source-validation ${validation.valid ? 'valid' : 'invalid'}">${esc(validationText)}</div>`;
    }
    if (frame.kind === 'chat') {
      return `<div class="chat-message"><div class="chat-speaker">${esc(frame.speaker || 'Không ghi người gửi')}${frame.branch ? ` · Nhánh ${frame.branch}` : ''}</div><div class="chat-text">${esc(frame.text)}</div></div>`;
    }
    if (frame.kind === 'choice') {
      return `<div class="description-frame choice-frame"><div class="frame-kind">Lựa chọn</div><h2>${esc(frame.title || 'Các lựa chọn xuất hiện')}</h2><div class="description-text">${esc(frame.text)}</div></div>`;
    }
    return `<div class="description-frame"><div class="frame-kind">Mô tả diễn biến cần thấy</div><h2>${esc(frame.title || 'Quan sát trong game')}</h2><div class="description-text">${esc(frame.text)}</div></div>`;
  }

  function facePortrait(file, index) {
    const safeIndex = Math.max(0, Math.min(7, Number(index) || 0));
    const x = safeIndex % 4;
    const y = Math.floor(safeIndex / 4);
    return `<div class="face-portrait" role="img" aria-label="${esc(file)}, ô ${safeIndex}" style="background-image:url('faces/${encodeURIComponent(file)}');background-position:-${x * 96}px -${y * 96}px"></div>`;
  }

  function nextId(prefix, records) {
    const max = records.reduce((value, record) => Math.max(value, parseInt(String(record.id || '').replace(/\D/g, ''), 10) || 0), 0);
    return `${prefix}-${String(max + 1).padStart(3, '0')}`;
  }

  function frameContext(type, item, frame) {
    return { type, typeLabel: typeLabel[type], itemId: item.id, itemTitle: item.title, itemGroup: item.group, frameId: frame.id, frameKind: frame.kind, frameSource: frame.source || '', expected: frame.text || '', speaker: frame.speaker || '', face: frame.face || '', faceIndex: frame.faceIndex ?? null, pop: Boolean(frame.pop) };
  }

  function openIssueModal(type, item, frame) {
    const wrap = $('#modalWrap');
    wrap.classList.remove('hidden');
    wrap.innerHTML = `<div class="modal-backdrop"><div class="modal"><div class="modal-head"><h2>Báo lỗi tại khung này</h2><button class="icon-btn" data-close>×</button></div><div class="form-grid">
      <div class="field"><span>Vị trí đã tự điền</span><div class="readonly"><strong>${esc(item.title)}</strong><br>${esc(frame.kind === 'dialogue' ? `${frame.speaker || 'Thoại'}: ${frame.text}` : `${frame.title}: ${frame.text}`)}<br><code>${esc(type)} / ${esc(item.id)} / ${esc(frame.id)}</code></div></div>
      <label class="field">Trong game thực tế đã xảy ra gì?<textarea id="bugActual" autofocus placeholder="Mô tả điều bạn nhìn thấy..."></textarea></label>
      <div class="form-grid two"><label class="field">Map / vị trí hiện tại<input id="bugLocation" placeholder="Ví dụ: Map3, gần bàn AlphaC61"></label><label class="field">Tần suất<select id="bugFrequency"><option>Mọi lần</option><option>Đôi lúc</option><option>Một lần</option><option>Chưa thử lại</option></select></label></div>
      <label class="field">Cách tái hiện<textarea id="bugRepro" placeholder="Mỗi bước một dòng"></textarea></label>
      <label class="field">Thông báo lỗi của game (nếu có)<textarea id="bugGameError" class="short-textarea"></textarea></label>
      <div class="field"><span>Ảnh / video / save</span><div class="attach-note">Chọn file sau khi đã đặt nó trong thư mục evidence tương ứng.</div><div class="attach-row"><button class="btn small" id="addImage">Gắn ảnh</button><button class="btn small" id="addVideo">Gắn video</button><button class="btn small" id="addSave">Gắn save</button></div><div id="attachedList" class="tags"></div></div>
      <div class="actions modal-actions"><button class="btn ghost" data-close>Hủy</button><button class="btn primary" id="saveIssue">Lưu báo lỗi</button></div>
    </div></div></div>`;
    const attachments = [];
    const close = () => { wrap.classList.add('hidden'); wrap.innerHTML = ''; };
    $$('[data-close]', wrap).forEach(button => button.onclick = close);
    const choose = (kind, folder, accept) => {
      const input = document.createElement('input');
      input.type = 'file'; input.accept = accept;
      input.onchange = () => {
        const file = input.files[0];
        if (!file) return;
        attachments.push({ kind, name: file.name, path: `evidence/${folder}/${file.name}` });
        $('#attachedList').innerHTML = attachments.map(entry => `<span class="tag">${esc(entry.name)}</span>`).join('');
      };
      input.click();
    };
    $('#addImage').onclick = () => choose('image', 'screenshots', 'image/*');
    $('#addVideo').onclick = () => choose('video', 'videos', 'video/*');
    $('#addSave').onclick = () => choose('save', 'saves', '*/*');
    $('#saveIssue').onclick = () => {
      const actual = $('#bugActual').value.trim();
      if (!actual) return alert('Hãy mô tả điều thực tế đã xảy ra trong game.');
      state.issues.push({
        id: nextId('BUG', state.issues), kind: 'bug', ...frameContext(type, item, frame),
        actual, location: $('#bugLocation').value.trim(), frequency: $('#bugFrequency').value,
        repro: $('#bugRepro').value.split(/\r?\n/).map(line => line.trim()).filter(Boolean),
        gameError: $('#bugGameError').value.trim(), evidence: attachments, createdAt: now()
      });
      save(); close(); renderDetail(type, item.id);
    };
  }

  function visibleCharacterCount(text) {
    const normalized = String(text).normalize('NFC');
    if (typeof Intl !== 'undefined' && Intl.Segmenter) {
      return [...new Intl.Segmenter('vi', { granularity: 'grapheme' }).segment(normalized)].length;
    }
    // Fallback cho trình duyệt cũ: bỏ các dấu Unicode đứng riêng sau khi tách chữ.
    return Array.from(normalized.normalize('NFD')).filter(character => !/\p{Mark}/u.test(character)).length;
  }

  function dialogueValidation(text, hasFace) {
    const lines = String(text).replace(/\r/g, '').split('\n');
    const limit = hasFace ? 33 : 40;
    // 33 là độ dài khuyến nghị có face; cho phép 34 vì mô tả thiết kế là “khoảng 33”.
    const hardLimit = hasFace ? 34 : 40;
    const details = lines.map((line, index) => {
      const length = visibleCharacterCount(line);
      return { line: index + 1, length, ok: length <= hardLimit, warning: length > limit && length <= hardLimit };
    });
    return { valid: lines.length <= 4 && details.every(detail => detail.ok), lines, limit, hardLimit, details };
  }

  function openSuggestionModal(type, item, frame) {
    const wrap = $('#modalWrap');
    const isDialogue = frame.kind === 'dialogue';
    wrap.classList.remove('hidden');
    wrap.innerHTML = `<div class="modal-backdrop"><div class="modal"><div class="modal-head"><h2>Đề xuất thay đổi</h2><button class="icon-btn" data-close>×</button></div><div class="form-grid">
      <div class="field"><span>Khung đang góp ý</span><div class="readonly"><strong>${esc(item.title)}</strong><br><code>${esc(type)} / ${esc(item.id)} / ${esc(frame.id)}</code></div></div>
      ${isDialogue ? `<label class="field">Người nói<input id="suggestSpeaker" value="${esc(frame.speaker || '')}"></label>
        <label class="field">Nội dung và xuống dòng<textarea id="suggestText" class="dialogue-editor">${esc(frame.text || '')}</textarea></label>
        <div id="textValidation" class="validation-box"></div>
        <div class="form-grid two"><label class="field">Face<select id="suggestFace"><option value="">Không dùng face</option>${FACES.map(file => `<option value="${esc(file)}" ${file === frame.face ? 'selected' : ''}>${esc(file)}</option>`).join('')}</select></label><label class="field">Ô face (0–7)<select id="suggestFaceIndex">${Array.from({ length: 8 }, (_, index) => `<option value="${index}" ${index === Number(frame.faceIndex || 0) ? 'selected' : ''}>${index}</option>`).join('')}</select></label></div>
        <label class="toggle-field"><input id="suggestPop" type="checkbox" ${frame.pop ? 'checked' : ''}><span>Đây là pop message</span></label>
        <div id="facePreview" class="face-preview"></div>` : `<label class="field">Mô tả đề xuất<textarea id="suggestText" autofocus>${esc(frame.text || '')}</textarea></label>`}
      <label class="field">Lý do thay đổi<textarea id="suggestReason" placeholder="Vì sao cách này rõ hơn hoặc hợp cảnh hơn?"></textarea></label>
      <div class="actions modal-actions"><button class="btn ghost" data-close>Hủy</button><button class="btn primary" id="saveSuggestion">Lưu đề xuất</button></div>
    </div></div></div>`;
    const close = () => { wrap.classList.add('hidden'); wrap.innerHTML = ''; };
    $$('[data-close]', wrap).forEach(button => button.onclick = close);
    let validation = { valid: true };
    const updateDialogue = () => {
      if (!isDialogue) return;
      const face = $('#suggestFace').value;
      const faceIndex = Number($('#suggestFaceIndex').value);
      validation = dialogueValidation($('#suggestText').value, Boolean(face));
      $('#textValidation').className = `validation-box ${validation.valid ? 'valid' : 'invalid'}`;
      const hasWarning = validation.details.some(detail => detail.warning);
      const headline = validation.valid ? (hasWarning ? '✓ Hợp lệ — sát giới hạn' : '✓ Thoại hợp lệ') : 'Cần sửa trước khi lưu';
      const limitText = validation.hardLimit > validation.limit ? `${validation.limit} khuyến nghị, tối đa ${validation.hardLimit}` : `tối đa ${validation.limit}`;
      $('#textValidation').innerHTML = `<strong>${headline}</strong><span>Tối đa 4 dòng · ${limitText} ký tự/dòng ${face ? 'khi có face' : 'khi không có face'}. Chữ Việt có dấu chỉ tính là 1 ký tự.</span><div>${validation.details.map(detail => `<span class="line-count ${detail.ok ? (detail.warning ? 'warning' : '') : 'over'}">D${detail.line}: ${detail.length}/${validation.hardLimit}</span>`).join('')}</div>`;
      $('#facePreview').innerHTML = face ? `${facePortrait(face, faceIndex)}<div><strong>${esc(face)}</strong><br><span class="muted small">Ô face ${faceIndex}</span></div>` : '<span class="muted small">Không dùng face — giới hạn 40 ký tự mỗi dòng.</span>';
      $('#suggestFaceIndex').disabled = !face;
      $('#saveSuggestion').disabled = !validation.valid;
    };
    if (isDialogue) {
      ['suggestText', 'suggestFace', 'suggestFaceIndex'].forEach(id => $(`#${id}`).addEventListener('input', updateDialogue));
      updateDialogue();
    }
    $('#saveSuggestion').onclick = () => {
      const text = $('#suggestText').value;
      if (!text.trim()) return alert('Nội dung đề xuất không được để trống.');
      if (isDialogue && !validation.valid) return alert('Thoại chưa đạt giới hạn dòng/ký tự.');
      const proposed = isDialogue ? {
        speaker: $('#suggestSpeaker').value.trim(), text,
        face: $('#suggestFace').value, faceIndex: $('#suggestFace').value ? Number($('#suggestFaceIndex').value) : null,
        pop: $('#suggestPop').checked
      } : { text };
      state.proposals.push({
        id: nextId('SUG', state.proposals), kind: 'suggestion', ...frameContext(type, item, frame),
        original: { text: frame.text || '', speaker: frame.speaker || '', face: frame.face || '', faceIndex: frame.faceIndex ?? null, pop: Boolean(frame.pop) },
        proposed, reason: $('#suggestReason').value.trim(), validation: isDialogue ? { maxLines: 4, recommendedCharsPerLine: validation.limit, maxCharsPerLine: validation.hardLimit, counting: 'Unicode grapheme clusters (vi)', lineLengths: validation.details.map(detail => detail.length) } : null,
        createdAt: now()
      });
      save(); close(); renderDetail(type, item.id);
    };
  }

  function renderResults() {
    $('#content').innerHTML = pageHead('Kết quả gửi đi', `${state.issues.length} lỗi · ${state.proposals.length} đề xuất`, '<button class="btn primary" id="exportResults">Xuất report.html + result.json</button>') + `
      <section><h2 class="section-title">Báo lỗi</h2>${state.issues.length ? `<div class="issue-list">${state.issues.slice().reverse().map(issueCard).join('')}</div>` : '<div class="card empty compact">Chưa có lỗi.</div>'}</section>
      <section><h2 class="section-title">Đề xuất nội dung</h2>${state.proposals.length ? `<div class="issue-list">${state.proposals.slice().reverse().map(proposalCard).join('')}</div>` : '<div class="card empty compact">Chưa có đề xuất.</div>'}</section>`;
    $('#exportResults').onclick = exportResults;
    $$('[data-delete-issue]').forEach(button => button.onclick = () => deleteRecord('issues', button.dataset.deleteIssue));
    $$('[data-delete-proposal]').forEach(button => button.onclick = () => deleteRecord('proposals', button.dataset.deleteProposal));
  }

  function deleteRecord(collection, id) {
    if (!confirm(`Xóa ${id}?`)) return;
    state[collection] = state[collection].filter(record => record.id !== id);
    save(); renderResults();
  }

  function contextLine(record) {
    return `${record.typeLabel || typeLabel[record.type] || ''} · ${record.itemTitle || ''} · khung ${record.frameId || ''}`;
  }

  function issueCard(issue) {
    return `<article class="issue-card"><div class="issue-head"><div><div class="issue-title">${esc(issue.id)} · Báo lỗi</div><div class="issue-context">${esc(contextLine(issue))}</div></div><button class="btn small ghost" data-delete-issue="${esc(issue.id)}">Xóa</button></div><div class="issue-body"><p><strong>Mong đợi:</strong> ${esc(issue.expected || issue.checkAction || '')}</p><p><strong>Thực tế:</strong> ${esc(issue.actual || issue.what || '')}</p>${issue.location ? `<p><strong>Vị trí:</strong> ${esc(issue.location)}</p>` : ''}${issue.repro?.length ? `<p><strong>Tái hiện:</strong></p><ol>${issue.repro.map(step => `<li>${esc(step)}</li>`).join('')}</ol>` : ''}<div class="fix-reference">Mã sửa: <code>${esc(issue.type || '')} / ${esc(issue.itemId || '')} / ${esc(issue.frameId || issue.checkKey || '')}</code></div>${evidenceGrid(issue.evidence)}</div></article>`;
  }

  function proposalCard(proposal) {
    const before = proposal.original || {};
    const after = proposal.proposed || {};
    return `<article class="issue-card proposal-card"><div class="issue-head"><div><div class="issue-title">${esc(proposal.id)} · Đề xuất</div><div class="issue-context">${esc(contextLine(proposal))}</div></div><button class="btn small ghost" data-delete-proposal="${esc(proposal.id)}">Xóa</button></div><div class="issue-body"><div class="change-grid"><div><strong>Hiện tại</strong><pre>${esc(before.text || proposal.expected || '')}</pre></div><div><strong>Đề xuất</strong><pre>${esc(after.text || '')}</pre></div></div>${proposal.frameKind === 'dialogue' ? `<p><strong>Người nói:</strong> ${esc(after.speaker || '—')} · <strong>Face:</strong> ${esc(after.face || 'không có')}${after.face ? ` [${after.faceIndex}]` : ''} · <strong>Pop:</strong> ${after.pop ? 'Có' : 'Không'}</p>` : ''}${proposal.reason ? `<p><strong>Lý do:</strong> ${esc(proposal.reason)}</p>` : ''}<div class="fix-reference">Mã sửa: <code>${esc(proposal.type)} / ${esc(proposal.itemId)} / ${esc(proposal.frameId)}</code></div></div></article>`;
  }

  function evidenceGrid(entries = []) {
    if (!entries.length) return '';
    return `<div class="evidence-grid">${entries.map(entry => {
      const path = esc(entry.path || '');
      if (entry.kind === 'image') return `<div class="evidence"><img src="${path}" alt="${esc(entry.name || '')}"><div class="evidence-name">${path}</div></div>`;
      if (entry.kind === 'video') return `<div class="evidence"><video src="${path}" controls></video><div class="evidence-name">${path}</div></div>`;
      return `<div class="evidence"><div class="evidence-save">Save: ${path}</div></div>`;
    }).join('')}</div>`;
  }

  function buildResult() {
    const summary = Object.fromEntries(Object.entries(types).map(([type, items]) => [type, completion(type, items)]));
    const items = Object.entries(types).flatMap(([type, collection]) => collection.map(item => {
      const frames = itemFrames(type, item);
      const okFrames = frames.filter(frame => frameIsOk(type, item, frame));
      return {
        type, itemId: item.id, title: item.title, group: item.group,
        status: itemStatus(type, item), frameCount: frames.length,
        okFrameIds: okFrames.map(frame => frame.id),
        currentFrameIndex: Number(state.positions[itemKey(type, item)] || 0) + 1
      };
    }));
    return {
      schemaVersion: 1, project: D.meta.title, contentVersion: D.meta.version,
      exportedAt: now(), summary, issues: state.issues, proposals: state.proposals, items,
      appState: state
    };
  }

  function exportResults() {
    const result = buildResult();
    const json = JSON.stringify(result, null, 2);
    const embedded = JSON.stringify(result).replace(/</g, '\\u003c');
    const report = `<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>WCF QA result</title><style>${reportCss()}</style></head><body><main><header><div><h1>Wonder Christmas Fiesta — Kết quả test</h1><p>Xuất lúc ${new Date().toLocaleString('vi-VN')}</p></div><button onclick="window.print()">In / PDF</button></header>${reportSummary(result)}<h2>Báo lỗi (${result.issues.length})</h2>${result.issues.length ? result.issues.map(reportIssue).join('') : '<p class="muted">Không có lỗi.</p>'}<h2>Đề xuất (${result.proposals.length})</h2>${result.proposals.length ? result.proposals.map(reportProposal).join('') : '<p class="muted">Không có đề xuất.</p>'}<h2>Tiến độ từng mục</h2>${reportItems(result.items)}</main><script id="wcf-report-data" type="application/json">${embedded}</script></body></html>`;
    downloadText('report.html', report, 'text/html');
    setTimeout(() => downloadText('result.json', json, 'application/json'), 180);
    setTimeout(() => alert('Đã xuất report.html và result.json. Hãy gửi hai file cùng thư mục evidence.'), 350);
  }

  function reportCss() {
    return `:root{font-family:system-ui,sans-serif;color:#18202d;background:#f5f7fb}body{margin:0}main{max-width:1100px;margin:auto;padding:30px}header{display:flex;justify-content:space-between;border-bottom:2px solid #d7ddea}h1{margin:0}h2{margin-top:30px}.muted,.context{color:#697386}.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-top:20px}.stats div,.record{background:#fff;border:1px solid #d7ddea;border-radius:10px;padding:14px}.stats b{display:block;font-size:24px}.record{margin:10px 0}.record h3{margin:0}.context{font-size:12px}.ref{background:#edf1f8;padding:8px;border-radius:6px;font-family:monospace}.change{display:grid;grid-template-columns:1fr 1fr;gap:10px}.change pre{white-space:pre-wrap;background:#f3f5f9;padding:10px}table{width:100%;border-collapse:collapse;background:#fff}th,td{padding:8px;border-bottom:1px solid #d7ddea;text-align:left;font-size:12px}@media(max-width:700px){.stats,.change{grid-template-columns:1fr 1fr}}@media print{button{display:none}}`;
  }

  function reportSummary(result) {
    return `<section class="stats">${Object.entries(result.summary).map(([type, value]) => `<div><small>${esc(typeLabel[type])}</small><b>${value.done}/${value.total}</b><span>${value.pct}% hoàn tất</span></div>`).join('')}</section>`;
  }

  function reportIssue(issue) {
    return `<article class="record"><h3>${esc(issue.id)} · Báo lỗi</h3><p class="context">${esc(contextLine(issue))}</p><p><b>Mong đợi:</b> ${esc(issue.expected || '')}</p><p><b>Thực tế:</b> ${esc(issue.actual || issue.what || '')}</p>${issue.location ? `<p><b>Vị trí:</b> ${esc(issue.location)}</p>` : ''}${issue.repro?.length ? `<ol>${issue.repro.map(step => `<li>${esc(step)}</li>`).join('')}</ol>` : ''}<p class="ref">${esc(issue.type)} / ${esc(issue.itemId)} / ${esc(issue.frameId || issue.checkKey || '')}</p></article>`;
  }

  function reportProposal(proposal) {
    return `<article class="record"><h3>${esc(proposal.id)} · Đề xuất</h3><p class="context">${esc(contextLine(proposal))}</p><div class="change"><div><b>Hiện tại</b><pre>${esc(proposal.original?.text || '')}</pre></div><div><b>Đề xuất</b><pre>${esc(proposal.proposed?.text || '')}</pre></div></div>${proposal.frameKind === 'dialogue' ? `<p><b>Face:</b> ${esc(proposal.proposed?.face || 'không có')} ${proposal.proposed?.face ? `[${proposal.proposed.faceIndex}]` : ''} · <b>Pop:</b> ${proposal.proposed?.pop ? 'Có' : 'Không'}</p>` : ''}${proposal.reason ? `<p><b>Lý do:</b> ${esc(proposal.reason)}</p>` : ''}<p class="ref">${esc(proposal.type)} / ${esc(proposal.itemId)} / ${esc(proposal.frameId)}</p></article>`;
  }

  function reportItems(items) {
    return `<table><thead><tr><th>Loại</th><th>Mã</th><th>Nội dung</th><th>Trạng thái</th><th>Khung OK</th></tr></thead><tbody>${items.map(item => `<tr><td>${esc(typeLabel[item.type])}</td><td>${esc(item.itemId)}</td><td>${esc(item.title)}</td><td>${esc(statusLabels[item.status])}</td><td>${item.okFrameIds.length}/${item.frameCount}</td></tr>`).join('')}</tbody></table>`;
  }

  function downloadText(name, text, mime) {
    const blob = new Blob([text], { type: mime });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob); link.download = name;
    document.body.appendChild(link); link.click();
    setTimeout(() => { URL.revokeObjectURL(link.href); link.remove(); }, 1000);
  }

  function importReport(file) {
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const text = String(reader.result);
        let data;
        if (file.name.toLowerCase().endsWith('.json')) data = JSON.parse(text);
        else {
          const match = text.match(/<script id=["']wcf-report-data["'] type=["']application\/json["']>([\s\S]*?)<\/script>/);
          if (!match) throw new Error('missing data');
          data = JSON.parse(match[1]);
        }
        state = normalizeState(data.appState || data);
        save(); route(); alert('Đã nhập kết quả và tiếp tục đúng khung đã lưu.');
      } catch (_) {
        alert('Không đọc được file báo cáo này.');
      }
    };
    reader.readAsText(file);
  }

  function globalSearch() {
    const input = $('#globalSearch');
    const results = $('#searchResults');
    input.addEventListener('input', () => {
      const query = input.value.trim().toLowerCase();
      if (query.length < 2) return results.classList.add('hidden');
      const found = allItems().filter(item => searchBlob(item).includes(query)).slice(0, 16);
      results.innerHTML = found.length ? found.map(item => `<a class="search-result" href="${itemHref(item._type, item.id)}">${esc(item.title)}<small>${esc(typeLabel[item._type])} · ${esc(item.group)}</small></a>`).join('') : '<div class="empty compact">Không có kết quả.</div>';
      results.classList.remove('hidden');
    });
    document.addEventListener('click', event => { if (!event.target.closest('.search-wrap')) results.classList.add('hidden'); });
  }

  function init() {
    updateNavCounts(); route(); globalSearch();
    window.addEventListener('hashchange', route);
    $('#exportBtn').onclick = exportResults;
    $('#importBtn').onclick = () => $('#importInput').click();
    $('#importInput').onchange = event => {
      const file = event.target.files[0];
      if (file) importReport(file);
      event.target.value = '';
    };
    $('#resetBtn').onclick = () => {
      if (!confirm('Xóa toàn bộ tiến độ, lỗi và đề xuất trên trình duyệt này?')) return;
      localStorage.removeItem(STORAGE_KEY);
      localStorage.removeItem(OLD_STORAGE_KEY);
      state = blankState(); save(); route();
    };
  }

  init();
})();
