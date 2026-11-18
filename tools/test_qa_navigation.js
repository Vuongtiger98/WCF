// Real Chromium regression test, isolated profile; no npm dependencies or tester data.
// node tools/test_qa_navigation.js [--observe] [--browser C:/path/to/chrome.exe]
const {spawn}=require('child_process');
const fs=require('fs');
const path=require('path');
const assert=require('assert');
const {pathToFileURL}=require('url');
const root=path.resolve(__dirname,'..');
const output=fs.mkdtempSync(path.join(root,'Save','QANavigationQA-'));
const browserArg=process.argv.indexOf('--browser');
const executable=browserArg>=0 ? process.argv[browserArg+1] : [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'
].find(candidate=>fs.existsSync(candidate));
if(!executable)throw new Error('Use --browser with a Chromium executable.');
const browser=spawn(executable,[
  '--headless=new','--remote-debugging-pipe','--no-first-run','--no-default-browser-check',
  '--disable-background-networking','--disable-component-update',
  '--user-data-dir='+path.join(output,'profile')
],{windowsHide:true,stdio:['ignore','pipe','pipe','pipe','pipe']});
let id=0,buffer='',errors='',session;
const pending=new Map(),exceptions=[];
browser.stdout.resume();browser.stderr.on('data',chunk=>errors+=chunk.toString());
browser.stdio[4].on('data',chunk=>{
  buffer+=chunk.toString();let end;
  while((end=buffer.indexOf('\0'))>=0){
    const message=JSON.parse(buffer.slice(0,end));buffer=buffer.slice(end+1);
    if(message.method==='Runtime.exceptionThrown')exceptions.push(message.params.exceptionDetails);
    const request=pending.get(message.id);
    if(request){pending.delete(message.id);clearTimeout(request.timeout);message.error?request.reject(message.error):request.resolve(message.result);}
  }
});
function call(method,params={},sessionId){
  return new Promise((resolve,reject)=>{
    const number=++id;
    const timeout=setTimeout(()=>{pending.delete(number);reject(new Error('CDP timeout: '+method));},8000);
    pending.set(number,{resolve,reject,timeout});
    browser.stdio[3].write(JSON.stringify({id:number,method,params,sessionId})+'\0');
  });
}
async function evaluate(expression){
  const result=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true},session);
  if(result.exceptionDetails)throw new Error(JSON.stringify(result.exceptionDetails));
  return result.result.value;
}
const pause=ms=>new Promise(resolve=>setTimeout(resolve,ms));
async function waitFor(expression){
  const deadline=Date.now()+5000;
  while(Date.now()<deadline){try{if(await evaluate(expression))return;}catch(_){}await pause(80);}
  throw new Error('Page not ready: '+expression);
}
async function shot(name){
  const image=await call('Page.captureScreenshot',{format:'png'},session);
  fs.writeFileSync(path.join(output,name+'.png'),Buffer.from(image.data,'base64'));
}
const deadline=setTimeout(()=>{browser.kill();console.error('BROWSER_TIMEOUT',errors);process.exit(1);},45000);
(async()=>{
  const {targetId}=await call('Target.createTarget',{url:'about:blank'});
  ({sessionId:session}=await call('Target.attachToTarget',{targetId,flatten:true}));
  await call('Page.enable',{},session);await call('Runtime.enable',{},session);
  await call('Emulation.setDeviceMetricsOverride',{width:1055,height:675,deviceScaleFactor:1,mobile:false},session);
  const url=pathToFileURL(path.join(root,'WonderChristmas_QA_Offline_V3/WonderChristmas_QA_Offline_V3/index.html')).href;
  await call('Page.navigate',{url:url+'#dialogues'},session);
  await waitFor('document.querySelectorAll(".item-card").length>100');
  // Seed valid old records to prove the UI update keeps existing progress intact.
  const seeded=await evaluate(`(()=>{
    const item=WCF_DIALOGUE_DATA.items[0],frame=item.frames[0],key='dialogue:'+item.id;
    const saved={version:3,contentVersion:WCF_CONTENT.meta.version,
      frames:{[key+':'+frame.id]:{ok:true,updatedAt:'2026-11-18T12:00:00Z'}},positions:{[key]:1},
      issues:[{id:'BUG-007',type:'dialogue',itemId:item.id,frameId:frame.id,actual:'Báo lỗi cũ',evidence:[]}],
      proposals:[{id:'SUG-009',type:'dialogue',itemId:item.id,frameId:frame.id,original:{text:frame.text},proposed:{text:'Đề xuất đã lưu'}}]};
    localStorage.setItem('wcf_qa_offline_v3',JSON.stringify(saved));return saved;
  })()`);
  await call('Page.reload',{},session);await waitFor('document.querySelectorAll(".item-card").length>100');
  await evaluate(`(()=>{const input=document.querySelector('#listSearch');input.value='Map';input.dispatchEvent(new Event('input',{bubbles:true}));
    const status=document.querySelector('#statusFilter');status.value='untested';status.dispatchEvent(new Event('input',{bubbles:true}));})()`);
  const target=await evaluate(`(()=>{
    const candidates=WCF_DIALOGUE_DATA.items.filter(item=>item.id!==${JSON.stringify(seeded.issues[0].itemId)}&&item.frames[0]?.kind==='dialogue'&&item.frames.length>1);
    const item=candidates[35];const hash='#item/dialogue/'+encodeURIComponent(item.id);
    document.querySelector('a[href="'+hash+'"]').scrollIntoView({block:'center'});return {hash,id:item.id,firstFrame:item.frames[0].id};
  })()`);
  await pause(120);
  const listBefore=await evaluate('({y:scrollY,search:document.querySelector("#listSearch").value,status:document.querySelector("#statusFilter").value})');
  await shot('list-before');
  await evaluate(`document.querySelector('a[href="${target.hash}"]').click()`);
  await waitFor('!!document.querySelector("#suggestChange")');
  await evaluate('window.scrollTo(0,document.documentElement.scrollHeight)');await pause(100);
  const detailBefore=await evaluate('scrollY');
  await evaluate('document.querySelector("#suggestChange").click()');
  await evaluate(`(()=>{const text=document.querySelector('#suggestText');text.value='Đề xuất thử nghiệm.';text.dispatchEvent(new Event('input',{bubbles:true}));document.querySelector('.modal').scrollTop=10000;})()`);
  await evaluate('document.querySelector("#saveSuggestion").click()');await pause(120);
  const detailAfter=await evaluate('scrollY');
  await shot('after-suggestion');
  await evaluate('history.back()');await waitFor('!!document.querySelector("#listSearch")');await pause(180);
  const listAfter=await evaluate('({y:scrollY,search:document.querySelector("#listSearch").value,status:document.querySelector("#statusFilter").value})');
  await shot('list-after-back');
  await evaluate(`document.querySelector('a[href="${target.hash}"]').click()`);await waitFor('!!document.querySelector("#nextFrame")');
  await evaluate('window.scrollTo(0,document.documentElement.scrollHeight)');await pause(100);
  const nextBefore=await evaluate('scrollY');
  await evaluate('document.querySelector("#nextFrame").click()');await pause(100);
  const nextAfter=await evaluate('scrollY');
  await evaluate('document.querySelector("#backFrame").click()');await pause(100);
  await evaluate('document.querySelector("#reportBug").click()');
  await evaluate('document.querySelector("#bugActual").value="Báo lỗi thử nghiệm";document.querySelector("#saveIssue").click()');await pause(100);
  const afterBug=await evaluate('scrollY');
  await evaluate('document.querySelector("#suggestChange").click();document.querySelector(".modal [data-close]").click()');await pause(100);
  const afterCancel=await evaluate('scrollY');
  await evaluate('document.querySelector(".breadcrumbs a").click()');await waitFor('!!document.querySelector("#listSearch")');await pause(180);
  const breadcrumbAfter=await evaluate('({y:scrollY,search:document.querySelector("#listSearch").value,status:document.querySelector("#statusFilter").value})');
  const saved=await evaluate('JSON.parse(localStorage.getItem("wcf_qa_offline_v3"))');
  await call('Page.reload',{},session);await waitFor('!!document.querySelector("#listSearch")');
  const reloaded=await evaluate('JSON.parse(localStorage.getItem("wcf_qa_offline_v3"))');
  const checks={
    detailScrollAfterSuggestion:Math.abs(detailAfter-detailBefore)<=2,
    browserBackScroll:Math.abs(listAfter.y-listBefore.y)<=2,
    browserBackFilters:listAfter.search===listBefore.search&&listAfter.status===listBefore.status,
    nextFrameScroll:Math.abs(nextAfter-nextBefore)<=2,
    reportAndCancelScroll:Math.abs(afterBug-nextBefore)<=2&&Math.abs(afterCancel-nextBefore)<=2,
    breadcrumbScroll:Math.abs(breadcrumbAfter.y-listBefore.y)<=2,
    breadcrumbFilters:breadcrumbAfter.search===listBefore.search&&breadcrumbAfter.status===listBefore.status,
    existingProgressKept:Object.entries(seeded.frames).every(([key,value])=>JSON.stringify(saved.frames[key])===JSON.stringify(value))&&Object.entries(seeded.positions).every(([key,value])=>saved.positions[key]===value),
    existingReportsKept:JSON.stringify(saved.issues[0])===JSON.stringify(seeded.issues[0])&&JSON.stringify(saved.proposals[0])===JSON.stringify(seeded.proposals[0]),
    newReportsCorrect:saved.issues.length===2&&saved.proposals.length===2&&saved.proposals[1].itemId===target.id&&saved.proposals[1].frameId===target.firstFrame&&saved.proposals[1].proposed.text==='Đề xuất thử nghiệm.',
    progressSurvivesReload:JSON.stringify(reloaded.frames)===JSON.stringify(saved.frames)&&JSON.stringify(reloaded.positions)===JSON.stringify(saved.positions)&&JSON.stringify(reloaded.issues)===JSON.stringify(saved.issues)&&JSON.stringify(reloaded.proposals)===JSON.stringify(saved.proposals),
    noScriptErrors:exceptions.length===0
  };
  const report={checks,listBefore,listAfter,breadcrumbAfter,detailBefore,detailAfter,nextBefore,nextAfter,afterBug,afterCancel,output};
  fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(report,null,2));
  console.log(JSON.stringify(report,null,2));
  if(!process.argv.includes('--observe'))assert(Object.values(checks).every(Boolean),'QA navigation regression; see results.json');
})().catch(error=>{console.error(error);process.exitCode=1;}).finally(async()=>{
  clearTimeout(deadline);try{await call('Browser.close');}catch(_){browser.kill();}
});
