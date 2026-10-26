import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';

/// Self-contained presentation bridge. The bundled generator is installed
/// directly from this compiled Dart library, so no web/pptx*.js file is needed.
/// It cannot be affected by wrong web-root paths, Flutter router fallback,
/// or CDN caching of the generator script.
@JS('displayRoomPptxV6Version')
external JSString? get _loadedVersion;

@JS('PptxGenJS')
external JSFunction? get _pptxLibrary;

@JS('generateDisplayRoomFullInfoV6')
external JSPromise<JSBoolean> _runV6(JSAny products, JSString fileName);

const _expectedVersion = 'FULL_INFO_V6_INLINE_20261026';
const _libraryUrl =
    'https://cdn.jsdelivr.net/npm/pptxgenjs/dist/pptxgen.bundle.js';

// Raw Dart string: the JS remains byte-for-byte valid, including template
// literals, RegExp backslashes, Unicode text and `${...}` expressions.
const _generatorSource = r'''/**
 * DISPLAY ROOM | STUDIO EDITION
 * Automatic client-ready PowerPoint catalogue, one selection or many.
 * Requires PptxGenJS (loaded by web/index.html).
 * Called by Dart through window.generateDisplayRoomFullInfoV6(products, fileName).
 * This generator never invents product facts and never alters Cart quantities.
 */
(function () {
  'use strict';
  const C = {
    charcoal: '17242A', charcoal2: '24343A', teal: '087F77', aqua: 'C7EEE6',
    coral: 'EF806B', cream: 'FAF8F3', warm: 'F2F0EA', white: 'FFFFFF',
    ink: '1B292F', gray: '67777B', border: 'DEE5E2', pale: 'EDF6F3',
    sand: 'EDE4DA', paleCoral: 'FFF0E9'
  };
  const W = 13.333, H = 7.5;
  const val = value => value == null || String(value).trim().toLowerCase() === 'null'
    ? '' : String(value).trim();
  const fallback = (v, text='Not provided') => val(v) || text;
  const num = v => Number.isFinite(Number(v))
    ? Number(v).toLocaleString('en-US', {maximumFractionDigits:2}) : fallback(v);
  const titleOf = (p,i) => fallback(p.description || p.itemName || p.itemCode, `Product ${i+1}`);
  const urlsOf = p => [...new Set((Array.isArray(p.images) && p.images.length
    ? p.images : [p.imageUrl]).map(val).filter(Boolean))].slice(0, 5);
  const dimensions = p => {
    const moq = p.moq == null || val(p.moq)==='' ? '' : `${num(p.moq)}${val(p.uom)?' '+val(p.uom):''}`;
    return [fallback(p.sizeRange), fallback(moq)];
  };
  function rect(slide, pptx, x, y, w, h, color, {radius=true, stroke=null, lineWidth=.7}={}) {
    slide.addShape(radius ? pptx.ShapeType.roundRect : pptx.ShapeType.rect,
      {x,y,w,h,rectRadius:.12,fill:{color},
        line: stroke ? {color:stroke,width:lineWidth} : {color,transparency:100}});
  }
  function line(slide,pptx,x,y,w,clr=C.border,width=.7) {
    slide.addShape(pptx.ShapeType.line,{x,y,w,h:0,line:{color:clr,width}});
  }
  function text(slide,value,x,y,w,h,opts={}) {
    slide.addText(String(value),{x,y,w,h,margin:0,fontFace:'Aptos',fontSize:12,
      color:C.ink,breakLine:false,valign:'mid',...opts});
  }
  function label(slide,s,x,y,w,opts={}) {
    text(slide,String(s).toUpperCase(),x,y,w,.20,
      {fontSize:8,bold:true,color:C.gray,charSpacing:1.2,...opts});
  }
  function pill(slide,pptx,value,x,y,w,{fill=C.aqua,color=C.charcoal,h=.42}={}) {
    rect(slide,pptx,x,y,w,h,fill);
    text(slide,value,x+.13,y+.02,w-.26,h-.04,
      {fontSize:9.2,bold:true,color,align:'center',fit:'shrink'});
  }
  function chrome(slide,pptx,page,section) {
    rect(slide,pptx,0,0,W,.105,C.coral,{radius:false});
    text(slide,'DISPLAY  /  ROOM',.57,.25,2.8,.31,
      {fontSize:12,bold:true,color:C.charcoal,charSpacing:.5});
    label(slide,section,7.8,.34,4.91,{align:'right'});
    line(slide,pptx,.59,7.13,12.13);
    text(slide,'PRODUCT SELECTION  •  FULL-INFO V6',.61,7.18,7,.18,
      {fontSize:7.3,color:C.gray,charSpacing:.45});
    text(slide,String(page).padStart(2,'0'),12.08,7.18,.53,.18,
      {fontSize:8,bold:true,color:C.teal,align:'right'});
  }
  // Two-density specification tile.  Compact cells are used by the
  // full-specifications slide as well as the information-packed hero slide.
  function specBox(slide,pptx,caption,value,x,y,w,h=.70,{fill=C.white}={}) {
    rect(slide,pptx,x,y,w,h,fill,{stroke:C.border});
    const compact=h<=.62;
    label(slide,caption,x+.12,y+(compact?.055:.11),w-.24,
      {fontSize:compact?7:7.7,charSpacing:compact?.5:.7});
    text(slide,fallback(value),x+.12,y+(compact?.205:.325),w-.24,
      compact ? .22 : Math.max(.24,h-.385),
      {fontSize:compact?10.0:11.4,bold:true,color:C.ink,fit:'shrink',valign:'mid'});
  }
  function photoPlaceholder(slide,pptx,x,y,w,h) {
    rect(slide,pptx,x,y,w,h,C.warm);
    text(slide,'IMAGE UNAVAILABLE',x+.20,y+h/2-.14,w-.40,.27,
      {fontSize:10,color:C.gray,bold:true,align:'center'});
  }
  async function loadPhoto(src) {
    if (!src) return null;
    if (src.startsWith('data:image/')) {
      if (typeof Image === 'undefined') return {data:src,w:1200,h:900}; // Node demo support
      return await new Promise(resolve=>{
        const img = new Image();
        img.onload=()=>resolve({data:src,w:img.naturalWidth,h:img.naturalHeight});
        img.onerror=()=>resolve(null); img.src=src;
      });
    }
    try {
      const response=await fetch(src,{mode:'cors'});
      if (!response.ok) throw new Error('Image HTTP '+response.status);
      const blob=await response.blob();
      if (blob.size>24*1024*1024) throw new Error('Photo too large for PPTX');
      const data=await new Promise((resolve,reject)=>{
        const reader=new FileReader();reader.onload=()=>resolve(reader.result);
        reader.onerror=reject;reader.readAsDataURL(blob);
      });
      return await new Promise(resolve=>{
        const img=new Image();
        img.onload=()=>resolve({data,w:img.naturalWidth,h:img.naturalHeight});
        img.onerror=()=>resolve(null);img.src=data;
      });
    } catch(e) {
      console.warn('PPTX photo unavailable (check ORDS image CORS):',src,e);
      return null;
    }
  }
  function showPhoto(slide,pptx,photo,x,y,w,h,{background=C.white}={}) {
    rect(slide,pptx,x,y,w,h,background);
    if (!photo?.data) {photoPlaceholder(slide,pptx,x,y,w,h);return;}
    const p=.12, bw=w-p*2,bh=h-p*2;
    const r=(photo.w||1)/Math.max(1,photo.h||1);
    let dw=bw,dh=bw/r;
    if(dh>bh){dh=bh;dw=bh*r;}
    try {slide.addImage({data:photo.data,x:x+(w-dw)/2,y:y+(h-dh)/2,w:dw,h:dh});}
    catch(e){console.warn('PPTX image embedding failed:',e); photoPlaceholder(slide,pptx,x,y,w,h);}
  }
  function allSpecs(p) {
    return [
      ['Item code',p.itemCode],['Business',p.business],['Category',p.category],
      ['Sub category',p.subCategory],['Size range',p.sizeRange],
      ['MOQ',p.moq == null ? '' : `${num(p.moq)}${val(p.uom)?' '+p.uom:''}`],
      ['UOM',p.uom],['Cart quantity',num(p.quantity||1)],
      ['Weight (g)',p.weightG==null?'':`${num(p.weightG)} g`],
      ['FOB',p.fob==null?'':num(p.fob)],['CBM',p.cbm],
      ['Material',p.material],['Sub inventory',p.subInventory],
      ['Organization ID',p.organizationId],['Display room',p.displayRoom],
      ['Status',p.status]
    ];
  }
  async function generateProductPresentation(products,fileName) {
    if(!Array.isArray(products)||!products.length) throw new Error('The cart is empty.');
    if(typeof PptxGenJS==='undefined') throw new Error('PowerPoint library not loaded.');
    const pptx=new PptxGenJS(); pptx.layout='LAYOUT_WIDE';
    pptx.author='Display Room';pptx.company='Display Room';
    pptx.title='Display Room | Product Lookbook';pptx.subject='Selected products and specifications';
    pptx.lang='en-US';
    pptx.theme={headFontFace:'Aptos Display',bodyFontFace:'Aptos',lang:'en-US'};
    const today=new Date().toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'});
    const sumQty=products.reduce((n,p)=>n+(Number(p.quantity)||0),0);
    const allUrls=[...new Set(products.flatMap(urlsOf))];
    const cache=new Map();
    // Limit simultaneous image requests for large carts.
    let imageCursor=0;
    async function imageWorker() {
      while (imageCursor<allUrls.length) {
        const url=allUrls[imageCursor++];
        cache.set(url,await loadPhoto(url));
      }
    }
    await Promise.all(Array.from({length:Math.min(4,allUrls.length)},()=>imageWorker()));
    let page=0;

    // COVER: bold two-tone editorial layout.
    {
      const s=pptx.addSlide();page++; s.background={color:C.charcoal};
      rect(s,pptx,0,0,.16,H,C.coral,{radius:false});
      rect(s,pptx,7.16,0,6.173,H,C.cream,{radius:false});
      label(s,'THE PRODUCT EDIT',.74,.68,4,{color:C.aqua,fontSize:10,charSpacing:3});
      text(s,'DISPLAY',.69,1.57,6.25,.95,{fontSize:53,bold:true,color:C.white});
      text(s,'ROOM',.69,2.48,6.25,.95,{fontSize:53,bold:true,color:C.white});
      text(s,'Premium product lookbook',.78,3.75,5.68,.53,
        {fontSize:22,color:'DAEAE8'});
      line(s,pptx,.77,4.52,5.59,C.gray,1);
      pill(s,pptx,`${products.length} PRODUCTS`,.78,4.96,1.94,{fill:C.aqua});
      pill(s,pptx,`${sumQty} CART UNITS`,2.91,4.96,1.9,{fill:C.coral,color:C.white});
      label(s,'GENERATED AUTOMATICALLY  /  '+today.toUpperCase(),.79,6.74,6,
        {color:'C9D9D7',fontSize:8.2});
      showPhoto(s,pptx,cache.get(urlsOf(products[0])[0]),7.65,.92,5.14,5.59,
        {background:C.white});
      text(s,'THE SELECTION  /  '+today.toUpperCase(),7.78,6.67,4.77,.25,
        {fontSize:9,bold:true,color:C.teal,charSpacing:1.0});
    }

    // OVERVIEW: automatically paginate for large carts.
    for(let start=0;start<products.length;start+=8){
      const s=pptx.addSlide();page++;s.background={color:C.cream};chrome(s,pptx,page,'SELECTION INDEX');
      label(s,'CURATED SELECTION',.60,.81,3,{color:C.teal});
      text(s,'Products at a glance',.59,1.14,10.8,.61,
        {fontSize:29,bold:true,color:C.charcoal});
      text(s,'MOQ = minimum order  •  QTY = quantity in your selection',.62,1.81,11,.25,
        {fontSize:10.3,color:C.gray});
      rect(s,pptx,.59,2.34,12.11,.43,C.charcoal,{radius:false});
      const xs=[.79,1.54,5.45,7.72,9.73,11.67];
      ['#','PRODUCT','CATEGORY','SIZE RANGE','MOQ','QTY'].forEach((v,k)=>
        label(s,v,xs[k],2.45,[.36,3.8,2.1,1.9,1.75,.58][k],
          {fontSize:7.8,color:C.white}));
      products.slice(start,start+8).forEach((p,i)=>{
        const global=start+i,y=2.90+i*.49;
        rect(s,pptx,.59,y,12.11,.445,i%2===0?C.white:C.warm,{radius:false});
        text(s,String(global+1).padStart(2,'0'),.79,y+.11,.40,.23,
          {fontSize:9.2,bold:true,color:C.teal});
        text(s,titleOf(p,global),1.54,y+.075,3.74,.30,
          {fontSize:10.3,bold:true,fit:'shrink'});
        text(s,fallback(p.category,'—'),5.45,y+.08,2.10,.27,{fontSize:9.3,fit:'shrink'});
        text(s,fallback(p.sizeRange,'—'),7.72,y+.08,1.9,.27,{fontSize:9.5});
        text(s,p.moq==null?'—':`${num(p.moq)} ${val(p.uom)}`,9.73,y+.08,1.75,.27,
          {fontSize:9.5,fit:'shrink'});
        text(s,num(p.quantity||1),11.67,y+.08,.58,.27,{fontSize:10,bold:true,align:'right'});
      });
      pill(s,pptx,`PAGE ${Math.floor(start/8)+1}  /  ${Math.ceil(products.length/8)}`,
        10.34,6.80,2.31,{fill:C.aqua,h:.27});
    }

    // COMPARISON: extra business value for multi-product catalogues.
    if(products.length>1){
      for(let start=0;start<products.length;start+=3){
        const chosen=products.slice(start,start+3);const s=pptx.addSlide();page++;
        s.background={color:C.cream};chrome(s,pptx,page,'PRODUCT COMPARISON');
        label(s,'SIDE BY SIDE',.63,.78,4,{color:C.teal});
        text(s,'Compare your selections',.61,1.11,11.8,.57,
          {fontSize:27,bold:true,color:C.charcoal});
        chosen.forEach((p,j)=>{
          const x=.61+j*4.19;
          rect(s,pptx,x,1.92,3.98,4.68,C.white,{stroke:C.border});
          showPhoto(s,pptx,cache.get(urlsOf(p)[0]),x+.14,2.08,3.69,1.99,
            {background:C.cream});
          text(s,titleOf(p,start+j),x+.20,4.18,3.52,.40,
            {fontSize:17,bold:true,color:C.charcoal,fit:'shrink'});
          line(s,pptx,x+.18,4.68,3.60,C.border);
          [['SIZE RANGE',p.sizeRange],['MOQ',p.moq==null?'':`${num(p.moq)} ${val(p.uom)}`],
          ['WEIGHT',p.weightG==null?'':`${num(p.weightG)} g`],
          ['CART QTY',num(p.quantity||1)]].forEach(([k,v],r)=>{
            label(s,k,x+.18,4.88+r*.37,1.43,{fontSize:7.3});
            text(s,fallback(v),x+1.62,4.82+r*.37,2.07,.28,
              {fontSize:10.4,bold:true,align:'right',fit:'shrink'});
          });
        });
      }
    }

    // PRODUCT: hero page + full specifications, plus gallery when available.
    for(let i=0;i<products.length;i++){
      const p=products[i],imgs=urlsOf(p),[size,moq]=dimensions(p);
      {
        // PRODUCT HERO - every available core attribute is visible on the
        // main slide, without requiring the viewer to advance to slide 2.
        const s=pptx.addSlide();page++;s.background={color:C.cream};chrome(s,pptx,page,
          `PRODUCT ${String(i+1).padStart(2,'0')}  /  ${String(products.length).padStart(2,'0')}`);
        pill(s,pptx,`ITEM ${String(i+1).padStart(2,'0')}`,.62,.75,1.40,
          {fill:C.charcoal,color:C.white,h:.33});
        text(s,titleOf(p,i),.61,1.18,10.35,.60,
          {fontSize:29,bold:true,color:C.charcoal,fit:'shrink'});
        pill(s,pptx,`CART  ${num(p.quantity||1)}`,11.20,1.27,1.47,
          {fill:C.coral,color:C.white,h:.42});
        text(s,`ITEM CODE: ${fallback(p.itemCode,'Not provided')}`, .63,1.82,6.39,.18,
          {fontSize:8.7,color:C.gray,bold:true,fit:'shrink'});
        showPhoto(s,pptx,cache.get(imgs[0]),.61,2.07,6.34,4.60,{background:C.white});
        label(s,`${imgs.length} PRODUCT ${imgs.length===1?'IMAGE':'IMAGES'}`,.82,6.80,4.1,
          {fontSize:7.2,color:C.teal});

        // TWO PRIMARY SALES FACTS
        rect(s,pptx,7.18,2.06,2.64,.97,C.charcoal);
        label(s,'SIZE RANGE',7.37,2.20,2.24,{color:'9CD1CA',fontSize:7.4});
        text(s,size,7.36,2.45,2.27,.38,
          {fontSize:22,bold:true,color:C.white,fit:'shrink'});
        rect(s,pptx,9.99,2.06,2.69,.97,C.aqua);
        label(s,'MINIMUM ORDER QTY',10.18,2.20,2.32,{color:C.teal,fontSize:7.25});
        text(s,moq,10.17,2.45,2.34,.38,
          {fontSize:21,bold:true,color:C.charcoal,fit:'shrink'});

        // CORE FACTS, VISIBLE IMMEDIATELY ON THE PRODUCT'S IMAGE SLIDE.
        const snapshot=[
          ['Business',p.business,'Category',p.category],
          ['Sub category',p.subCategory,'UOM',p.uom],
          ['Weight (g)',p.weightG==null?'':`${num(p.weightG)} g`,'FOB',p.fob==null?'':num(p.fob)],
          ['CBM',p.cbm,'Sub inventory',p.subInventory],
          ['Organization ID',p.organizationId,'Display room',p.displayRoom],
        ];
        snapshot.forEach(([k1,v1,k2,v2],r)=>{
          const y=3.17+r*.545;
          specBox(s,pptx,k1,v1,7.18,y,2.64,.48);
          specBox(s,pptx,k2,v2,9.99,y,2.69,.48);
        });
        specBox(s,pptx,'Material specification',p.material,7.18,5.95,5.50,.64,
          {fill:C.pale});
      }
      {
        const s=pptx.addSlide();page++;s.background={color:C.cream};chrome(s,pptx,page,'FULL PRODUCT SPECIFICATIONS');
        label(s,'THE DETAILS',.62,.85,4,{color:C.teal});
        text(s,titleOf(p,i),.62,1.20,11.90,.60,
          {fontSize:26,bold:true,color:C.charcoal,fit:'shrink'});
        const specs=allSpecs(p);
        specs.forEach(([k,v],j)=>{
          const col=j%2,row=Math.floor(j/2),x=.62+col*6.19,y=2.06+row*.56;
          specBox(s,pptx,k,v,x,y,5.95,.49);
        });
        text(s,'All values are taken from available product records. Missing fields are marked “Not provided”.',
          .66,6.72,11.9,.20,{fontSize:9,color:C.gray});
      }
      if(imgs.length>1){
        for(let start=0;start<imgs.length;start+=4){
          const s=pptx.addSlide();page++;s.background={color:C.cream};
          chrome(s,pptx,page,'PHOTO GALLERY');
          label(s,'ADDITIONAL VIEWS',.62,.80,4,{color:C.teal});
          text(s,titleOf(p,i),.62,1.15,11.92,.62,
            {fontSize:27,bold:true,color:C.charcoal,fit:'shrink'});
          imgs.slice(start,start+4).forEach((u,j)=>{
            const x=.62+(j%2)*6.20,y=2.0+Math.floor(j/2)*2.40;
            showPhoto(s,pptx,cache.get(u),x,y,5.91,2.08);
            label(s,`VIEW ${String(start+j+1).padStart(2,'0')}`,x+.12,y+2.12,3.5,
              {fontSize:8,color:C.teal});
          });
        }
      }
    }

    // CLOSING slide.
    {
      const s=pptx.addSlide();page++;s.background={color:C.charcoal};
      rect(s,pptx,0,0,W,.17,C.coral,{radius:false});
      label(s,'DISPLAY ROOM  /  PRODUCT LOOKBOOK',.9,.86,9,
        {color:C.aqua,fontSize:10,charSpacing:2.2});
      text(s,'THANK YOU',.88,2.08,11.54,1.15,
        {fontSize:62,bold:true,color:C.white,align:'center'});
      text(s,'Your selected products, all in one place.',2.08,3.47,9.18,.50,
        {fontSize:20,color:'D6E4E1',align:'center'});
      pill(s,pptx,`${products.length} PRODUCTS  /  ${sumQty} CART UNITS`,
        4.16,4.58,5.01,{fill:C.coral,color:C.white,h:.51});
      label(s,today.toUpperCase(),4.40,6.67,4.51,
        {align:'center',color:'D4E0DD',fontSize:9});
    }
    await pptx.writeFile({fileName:fileName||`Display_Room_Studio_${Date.now()}.pptx`,compression:true});
    return true;
  }
  if(typeof window!=='undefined') {
    // Independent V6 namespace; legacy pptx_generator.js can remain loaded.
    Object.defineProperty(window, 'displayRoomPptxV6Version', {
      value: 'FULL_INFO_V6_INLINE_20261026', writable: false, configurable: true
    });
    Object.defineProperty(window, 'generateDisplayRoomFullInfoV6', {
      value: generateProductPresentation, writable: false, configurable: true
    });
    console.info('[Display Room PPTX] FULL_INFO_V6_INLINE_20261026 loaded — full information enabled');
  }
  // Only for Node preview testing; no effect in browser.
  else if(typeof global!=='undefined') global.generateProductPresentation=generateProductPresentation;
})();
''';

Future<void>? _pendingInit;

Future<void> _loadPptxLibraryIfNeeded() async {
  if (_pptxLibrary != null) return;
  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..src = _libraryUrl
    ..type = 'text/javascript';
  final a = script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  final b = script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(StateError(
        'PptxGenJS CDN script did not load. Check network access: $_libraryUrl',
      ));
    }
  });
  html.document.head!.append(script);
  try {
    await completer.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw StateError('PptxGenJS library load timed out.'),
    );
  } finally {
    await a.cancel();
    await b.cancel();
  }
  if (_pptxLibrary == null) {
    throw StateError('PptxGenJS loaded but did not register its global class.');
  }
}

Future<void> _prepare() async {
  if (_loadedVersion?.toDart == _expectedVersion) return;
  await _loadPptxLibraryIfNeeded();
  // Inline script installs synchronously. This is intentionally NOT an
  // HTTP request for /pptx_fullinfo_v5_autoload.js.
  final element = html.ScriptElement()
    ..type = 'text/javascript'
    ..text = _generatorSource;
  html.document.head!.append(element);
  if (_loadedVersion?.toDart != _expectedVersion) {
    element.remove();
    throw StateError(
      'Embedded PPTX V6 initialization failed. '
          'Check browser F12 Console for the actual JavaScript or Content-Security-Policy error. '
          'Found: ${_loadedVersion?.toDart ?? "none"}',
    );
  }
}

Future<void> generateProductPresentation(
    List<Map<String, Object?>> products,
    String fileName,
    ) async {
  if (products.isEmpty) throw StateError('No products selected.');
  _pendingInit ??= _prepare();
  try {
    await _pendingInit;
  } catch (_) {
    _pendingInit = null; // retry if CDN/network was temporarily unavailable
    rethrow;
  }
  final data = products.jsify();
  if (data == null) throw StateError('Failed to encode product selection.');
  await _runV6(data, fileName.toJS).toDart;
}
