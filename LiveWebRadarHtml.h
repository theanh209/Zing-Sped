#pragma once

// File: LiveWebRadarHtml.h
// Tu dong sinh tu live_web_radar.html cho Web Radar Server

static const char* kLiveWebRadarHtml = R"RAW_RADAR_HTML(
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>ZingSpeed Mobile - Live Web Radar & Telemetry</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background-color: #0b0f19;
      color: #e2e8f0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      overflow: hidden;
      width: 100vw;
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background: rgba(15, 23, 42, 0.85);
      backdrop-filter: blur(12px);
      border-bottom: 1px solid rgba(56, 189, 248, 0.2);
      padding: 10px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      z-index: 10;
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .brand-logo {
      width: 32px;
      height: 32px;
      background: linear-gradient(135deg, #0ea5e9, #38bdf8);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 900;
      color: #000;
      box-shadow: 0 0 15px rgba(14, 165, 233, 0.5);
    }
    .brand-title h1 {
      font-size: 15px;
      font-weight: 700;
      letter-spacing: 0.5px;
      color: #f8fafc;
    }
    .brand-title p {
      font-size: 11px;
      color: #94a3b8;
    }
    .status-badge {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 6px 14px;
      background: rgba(16, 185, 129, 0.15);
      border: 1px solid rgba(16, 185, 129, 0.3);
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      color: #34d399;
    }
    .status-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: #10b981;
      box-shadow: 0 0 8px #10b981;
      animation: pulse 1.8s infinite;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.85); }
    }
    #viewport {
      position: relative;
      flex: 1;
      width: 100%;
      height: 100%;
    }
    canvas {
      display: block;
      width: 100%;
      height: 100%;
      cursor: grab;
    }
    canvas:active { cursor: grabbing; }
    .controls-overlay {
      position: absolute;
      top: 16px;
      right: 16px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      z-index: 5;
    }
    .btn {
      background: rgba(15, 23, 42, 0.85);
      backdrop-filter: blur(8px);
      border: 1px solid rgba(56, 189, 248, 0.3);
      color: #f1f5f9;
      padding: 8px 14px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s ease;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    }
    .btn:hover {
      background: rgba(14, 165, 233, 0.25);
      border-color: #38bdf8;
      box-shadow: 0 0 12px rgba(56, 189, 248, 0.4);
    }
    .btn.active {
      background: #0ea5e9;
      color: #fff;
      border-color: #38bdf8;
    }
    .telemetry-card {
      position: absolute;
      bottom: 20px;
      left: 20px;
      background: rgba(15, 23, 42, 0.88);
      backdrop-filter: blur(14px);
      border: 1px solid rgba(56, 189, 248, 0.25);
      border-radius: 14px;
      padding: 16px 20px;
      min-width: 280px;
      z-index: 5;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }
    .telem-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }
    .telem-label {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: #94a3b8;
    }
    .telem-value {
      font-size: 14px;
      font-weight: 700;
      font-family: monospace;
      color: #38bdf8;
    }
    .speed-display {
      font-size: 38px;
      font-weight: 900;
      color: #f8fafc;
      line-height: 1;
      text-shadow: 0 0 20px rgba(56, 189, 248, 0.5);
    }
    .speed-unit {
      font-size: 14px;
      color: #38bdf8;
      font-weight: 600;
      margin-left: 4px;
    }
    .bar-container {
      width: 100%;
      height: 6px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 3px;
      overflow: hidden;
      margin-top: 6px;
    }
    .bar-fill {
      height: 100%;
      background: linear-gradient(90deg, #0ea5e9, #38bdf8, #a855f7);
      width: 75%;
      border-radius: 3px;
      transition: width 0.1s linear;
    }
    .radar-legend {
      position: absolute;
      bottom: 20px;
      right: 20px;
      background: rgba(15, 23, 42, 0.88);
      backdrop-filter: blur(14px);
      border: 1px solid rgba(56, 189, 248, 0.2);
      border-radius: 12px;
      padding: 12px 16px;
      font-size: 12px;
      z-index: 5;
    }
    .legend-item {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 6px;
    }
    .legend-item:last-child { margin-bottom: 0; }
    .dot-you { width: 10px; height: 10px; border-radius: 50%; background: #38bdf8; box-shadow: 0 0 8px #38bdf8; }
    .dot-enemy { width: 10px; height: 10px; border-radius: 50%; background: #ef4444; box-shadow: 0 0 8px #ef4444; }
    .dot-apex { width: 10px; height: 10px; border-radius: 50%; background: #eab308; box-shadow: 0 0 8px #eab308; }
  </style>
</head>
<body>
  <header>
    <div class="brand">
      <div class="brand-logo">ZS</div>
      <div class="brand-title">
        <h1>ZING SPEED LIVE RADAR PC</h1>
        <p>Hệ thống định vị & truyền hình trực tiếp đường đua</p>
      </div>
    </div>
    <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
      <input type="text" id="hostInput" placeholder="IP iPhone (VD: 192.168.1.15:8088)" style="background: rgba(15,23,42,0.85); border: 1px solid rgba(56,189,248,0.4); color: #fff; padding: 5px 10px; border-radius: 6px; font-size: 11px; width: 175px;">
      <button class="btn" id="btnConnect" style="padding: 5px 10px;">⚡ Kết Nối</button>
      <select id="mapSelect" class="btn" style="padding: 6px 12px;">
        <option value="0">Map 157 - Hồ Long Tỉnh</option>
        <option value="1">Map 102 - Thành Phố 11</option>
        <option value="2">Map 120 - Đảo 11</option>
        <option value="3">Map 145 - Thu Danh Sơn</option>
        <option value="4">Map 188 - Suối Nước Nóng</option>
        <option value="5">Map 210 - Sa Mạc Tốc Độ</option>
      </select>
      <div class="status-badge" id="connStatus">
        <div class="status-dot"></div>
        <span id="connText">KẾT NỐI REALTIME (60 FPS)</span>
      </div>
    </div>
  </header>

  <div id="viewport">
    <canvas id="radarCanvas"></canvas>

    <div class="controls-overlay">
      <button class="btn active" id="btnFollow">🎯 Khóa Theo Xe</button>
      <button class="btn" id="btnResetView">🔍 Reset Góc Nhìn</button>
      <button class="btn" id="btnZoomIn">➕ Phóng To</button>
      <button class="btn" id="btnZoomOut">➖ Thu Nhỏ</button>
    </div>

    <div class="telemetry-card">
      <div class="telem-row">
        <span class="telem-label">VẬN TỐC HIỆN TẠI</span>
        <span class="telem-value" id="mapName">Hồ Long Tỉnh</span>
      </div>
      <div style="margin-bottom: 12px;">
        <span class="speed-display" id="speedVal">238</span><span class="speed-unit">KM/H</span>
      </div>
      <div class="telem-row">
        <span class="telem-label">Góc Drift (Slip Angle)</span>
        <span class="telem-value" id="driftVal">34.2°</span>
      </div>
      <div class="telem-row">
        <span class="telem-label">Tọa Độ (X, Z)</span>
        <span class="telem-value" id="coordsVal">124.5, -42.8</span>
      </div>
      <div class="telem-row">
        <span class="telem-label">Mốc Waypoint</span>
        <span class="telem-value" id="wpVal">5 / 12</span>
      </div>
      <div class="telem-row" style="margin-top: 10px; margin-bottom: 4px;">
        <span class="telem-label">Thanh Nạp Nitro CWW</span>
        <span class="telem-value" id="nitroVal">85%</span>
      </div>
      <div class="bar-container">
        <div class="bar-fill" id="nitroBar"></div>
      </div>
    </div>

    <div class="radar-legend">
      <div class="legend-item"><div class="dot-you"></div><span>Xe của bạn (Player)</span></div>
      <div class="legend-item"><div class="dot-enemy"></div><span>Đối thủ (Opponents)</span></div>
      <div class="legend-item"><div class="dot-apex"></div><span>Đỉnh Apex Cua Tối Ưu</span></div>
    </div>
  </div>

  <script>
    const canvas = document.getElementById('radarCanvas');
    const ctx = canvas.getContext('2d');
    const mapSelect = document.getElementById('mapSelect');
    const btnFollow = document.getElementById('btnFollow');
    const btnResetView = document.getElementById('btnResetView');
    const btnZoomIn = document.getElementById('btnZoomIn');
    const btnZoomOut = document.getElementById('btnZoomOut');

    // Telemetry DOM
    const speedVal = document.getElementById('speedVal');
    const driftVal = document.getElementById('driftVal');
    const coordsVal = document.getElementById('coordsVal');
    const wpVal = document.getElementById('wpVal');
    const nitroVal = document.getElementById('nitroVal');
    const nitroBar = document.getElementById('nitroBar');
    const mapName = document.getElementById('mapName');

    const mapWaypoints = [
      // Map 0: Hồ Long Tỉnh
      [
        {x: 0, y: 0}, {x: 35, y: 85}, {x: 120, y: 160}, {x: 210, y: 190},
        {x: 310, y: 150}, {x: 380, y: 60}, {x: 360, y: -60}, {x: 280, y: -150},
        {x: 160, y: -190}, {x: 60, y: -160}, {x: -20, y: -90}, {x: 0, y: 0}
      ],
      // Map 1: Thành Phố 11
      [
        {x: 0, y: 0}, {x: 0, y: 150}, {x: 45, y: 210}, {x: 160, y: 210},
        {x: 220, y: 160}, {x: 220, y: 40}, {x: 280, y: -10}, {x: 390, y: -10},
        {x: 450, y: -70}, {x: 450, y: -220}, {x: 390, y: -280}, {x: 180, y: -280},
        {x: 60, y: -180}, {x: 0, y: 0}
      ],
      // Map 2: Đảo 11
      [
        {x: 0, y: 0}, {x: -40, y: 95}, {x: -110, y: 190}, {x: -80, y: 290},
        {x: 20, y: 350}, {x: 130, y: 320}, {x: 190, y: 220}, {x: 170, y: 110},
        {x: 240, y: 30}, {x: 200, y: -80}, {x: 80, y: -90}, {x: 0, y: 0}
      ],
      // Map 3: Thu Danh Sơn
      [
        {x: 0, y: 0}, {x: 25, y: 110}, {x: 90, y: 160}, {x: 15, y: 220},
        {x: 85, y: 280}, {x: 10, y: 340}, {x: 80, y: 400}, {x: 15, y: 460},
        {x: 120, y: 520}, {x: 210, y: 450}, {x: 190, y: 320}, {x: 230, y: 210},
        {x: 180, y: 110}, {x: 120, y: 40}, {x: 40, y: -30}, {x: 0, y: 0}
      ],
      // Map 4: Suối Nước Nóng
      [
        {x: 0, y: 0}, {x: -30, y: 80}, {x: -90, y: 140}, {x: -140, y: 240},
        {x: -90, y: 330}, {x: 30, y: 360}, {x: 140, y: 300}, {x: 180, y: 190},
        {x: 220, y: 90}, {x: 170, y: -20}, {x: 70, y: -60}, {x: 0, y: 0}
      ],
      // Map 5: Sa Mạc Tốc Độ
      [
        {x: 0, y: 0}, {x: 60, y: 140}, {x: 180, y: 260}, {x: 320, y: 310},
        {x: 450, y: 240}, {x: 520, y: 110}, {x: 480, y: -40}, {x: 360, y: -160},
        {x: 220, y: -220}, {x: 90, y: -180}, {x: 10, y: -80}, {x: 0, y: 0}
      ]
    ];

    let currentMapIdx = 0;
    let camera = { x: 150, y: 0, scale: 1.1 };
    let isFollowPlayer = true;
    let isDragging = false;
    let dragStart = { x: 0, y: 0 };

    // Player State
    let player = {
      x: 0, y: 0, yaw: 0, speed: 225, driftAngle: 0, nitro: 85, progress: 0
    };

    // Simulated Opponents
    let opponents = [
      { id: 1, name: "Bảo Long", x: 0, y: 0, yaw: 0, progress: 0.12, color: "#ef4444" },
      { id: 2, name: "Hoàng Minh", x: 0, y: 0, yaw: 0, progress: -0.08, color: "#f97316" },
      { id: 3, name: "Zhee VIP", x: 0, y: 0, yaw: 0, progress: 0.25, color: "#a855f7" }
    ];

    function resize() {
      const dpr = window.devicePixelRatio || 1;
      canvas.width = canvas.parentElement.clientWidth * dpr;
      canvas.height = canvas.parentElement.clientHeight * dpr;
      ctx.scale(dpr, dpr);
    }
    window.addEventListener('resize', resize);
    resize();

    // Catmull-Rom Spline point evaluation
    function getSplinePoint(pts, t) {
      const n = pts.length;
      const f = (t % 1) * n;
      const i1 = Math.floor(f) % n;
      const i0 = (i1 - 1 + n) % n;
      const i2 = (i1 + 1) % n;
      const i3 = (i1 + 2) % n;
      const localT = f - Math.floor(f);

      const p0 = pts[i0], p1 = pts[i1], p2 = pts[i2], p3 = pts[i3];
      const t2 = localT * localT;
      const t3 = t2 * localT;

      return {
        x: 0.5 * ((2*p1.x) + (-p0.x + p2.x)*localT + (2*p0.x - 5*p1.x + 4*p2.x - p3.x)*t2 + (-p0.x + 3*p1.x - 3*p2.x + p3.x)*t3),
        y: 0.5 * ((2*p1.y) + (-p0.y + p2.y)*localT + (2*p0.y - 5*p1.y + 4*p2.y - p3.y)*t2 + (-p0.y + 3*p1.y - 3*p2.y + p3.y)*t3)
      };
    }

    // Interactive mouse / touch events
    canvas.addEventListener('mousedown', (e) => {
      isDragging = true;
      dragStart = { x: e.clientX, y: e.clientY };
    });
    window.addEventListener('mousemove', (e) => {
      if (isDragging) {
        isFollowPlayer = false;
        btnFollow.classList.remove('active');
        camera.x += (e.clientX - dragStart.x) / camera.scale;
        camera.y += (e.clientY - dragStart.y) / camera.scale;
        dragStart = { x: e.clientX, y: e.clientY };
      }
    });
    window.addEventListener('mouseup', () => { isDragging = false; });
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      const zoomFactor = e.deltaY < 0 ? 1.15 : 0.85;
      camera.scale = Math.min(Math.max(camera.scale * zoomFactor, 0.2), 4.0);
    }, { passive: false });

    btnFollow.addEventListener('click', () => {
      isFollowPlayer = true;
      btnFollow.classList.add('active');
    });
    btnResetView.addEventListener('click', () => {
      camera = { x: 150, y: 0, scale: 1.1 };
      isFollowPlayer = true;
      btnFollow.classList.add('active');
    });
    btnZoomIn.addEventListener('click', () => { camera.scale = Math.min(camera.scale * 1.25, 4.0); });
    btnZoomOut.addEventListener('click', () => { camera.scale = Math.max(camera.scale * 0.8, 0.2); });
    mapSelect.addEventListener('change', (e) => {
      currentMapIdx = parseInt(e.target.value);
      player.progress = 0;
      mapName.innerText = e.target.options[e.target.selectedIndex].text.split(' - ')[1];
    });

    // Live Telemetry Sync with ZingSpeed iPhone Tweak
    let liveConnected = false;
    let customHost = (window.location.origin && window.location.origin.startsWith('http')) ? window.location.origin : '';
    const hostInput = document.getElementById('hostInput');
    const btnConnect = document.getElementById('btnConnect');

    if (customHost) {
      hostInput.value = customHost;
    }

    btnConnect.addEventListener('click', () => {
      let val = hostInput.value.trim();
      if (!val) return;
      if (!val.startsWith('http://') && !val.startsWith('https://')) {
        val = 'http://' + val;
      }
      customHost = val;
      fetchTelemetry();
    });

    async function fetchTelemetry() {
      const target = customHost || (window.location.origin.startsWith('http') ? window.location.origin : '');
      if (!target) return;
      try {
        const url = target.replace(/\/+$/, '') + '/telemetry';
        const res = await fetch(url, { cache: 'no-store' });
        if (res.ok) {
          const data = await res.json();
          liveConnected = true;
          document.getElementById('connText').innerText = 'LIVE iPHONE: ' + (data.ip || target);
          document.getElementById('connStatus').style.background = 'rgba(16, 185, 129, 0.25)';
          document.getElementById('connStatus').style.color = '#34d399';

          if (data.mapIdx !== undefined && data.mapIdx >= 0 && data.mapIdx < 6) {
            if (currentMapIdx !== data.mapIdx) {
              currentMapIdx = data.mapIdx;
              mapSelect.value = data.mapIdx;
              mapName.innerText = mapSelect.options[mapSelect.selectedIndex].text.split(' - ')[1];
            }
          }

          player.x += (data.x - player.x) * 0.45;
          player.y += (data.z - player.y) * 0.45;
          player.yaw = data.yaw;
          player.speed = data.speed;
          player.driftAngle = data.driftAngle;
          player.nitro = data.nitro;

          if (data.opponents && data.opponents.length > 0) {
            data.opponents.forEach((op, i) => {
              if (!opponents[i]) {
                opponents[i] = { name: op.name, color: op.color, progress: 0, x: op.x, y: op.y, yaw: op.yaw };
              } else {
                opponents[i].x += (op.x - opponents[i].x) * 0.35;
                opponents[i].y += (op.y - opponents[i].y) * 0.35;
                opponents[i].yaw = op.yaw;
                opponents[i].name = op.name;
                opponents[i].color = op.color;
              }
            });
          }

          if (data.wp !== undefined) {
            wpVal.innerText = `${data.wp} / ${data.totalWp || mapWaypoints[currentMapIdx].length}`;
          }
        }
      } catch (e) {
        liveConnected = false;
        document.getElementById('connText').innerText = 'CHỜ KẾT NỐI (DEMO CHẠY THỬ)';
        document.getElementById('connStatus').style.background = 'rgba(234, 179, 8, 0.15)';
        document.getElementById('connStatus').style.color = '#eab308';
      }
    }

    setInterval(fetchTelemetry, 45); // ~22 FPS real-time polling

    // Main Simulation & Render Loop
    let lastTime = performance.now();
    function animate(time) {
      const dt = Math.min((time - lastTime) / 1000, 0.1);
      lastTime = time;

      const pts = mapWaypoints[currentMapIdx];

      if (!liveConnected) {
        // Fallback smooth spline odometry simulation
        player.progress += dt * 0.055;
        const pCurrent = getSplinePoint(pts, player.progress);
        const pAhead = getSplinePoint(pts, player.progress + 0.005);

        player.x = pCurrent.x;
        player.y = pCurrent.y;
        player.yaw = Math.atan2(pAhead.x - pCurrent.x, pAhead.y - pCurrent.y) * (180 / Math.PI);
        player.speed = 220 + Math.sin(time * 0.003) * 35;
        player.driftAngle = Math.abs(Math.sin(time * 0.004)) > 0.4 ? 32 + Math.sin(time * 0.01) * 8 : 4;
        player.nitro = (player.nitro + dt * 15) % 100;

        opponents.forEach(op => {
          const opPos = getSplinePoint(pts, player.progress + op.progress);
          const opAhead = getSplinePoint(pts, player.progress + op.progress + 0.005);
          op.x = opPos.x;
          op.y = opPos.y;
          op.yaw = Math.atan2(opAhead.x - opPos.x, opAhead.y - opPos.y) * (180 / Math.PI);
        });

        wpVal.innerText = `${Math.floor((player.progress % 1) * pts.length) + 1} / ${pts.length}`;
      }

      // Camera auto-follow
      if (isFollowPlayer) {
        camera.x = -player.x;
        camera.y = -player.y;
      }

      // Update DOM
      speedVal.innerText = Math.round(player.speed);
      driftVal.innerText = player.driftAngle.toFixed(1) + "°";
      coordsVal.innerText = `${player.x.toFixed(1)}, ${player.y.toFixed(1)}`;
      nitroVal.innerText = `${Math.round(player.nitro)}%`;
      nitroBar.style.width = `${player.nitro}%`;

      render();
      requestAnimationFrame(animate);
    }

    function render() {
      const w = canvas.parentElement.clientWidth;
      const h = canvas.parentElement.clientHeight;

      ctx.save();
      ctx.clearRect(0, 0, w, h);

      // Center origin and apply camera
      ctx.translate(w / 2, h / 2);
      ctx.scale(camera.scale, camera.scale);
      ctx.translate(camera.x, camera.y);

      // 1. Draw Cyberpunk Grid
      ctx.strokeStyle = "rgba(56, 189, 248, 0.06)";
      ctx.lineWidth = 1;
      const gridSize = 60;
      for (let x = -1000; x <= 1000; x += gridSize) {
        ctx.beginPath();
        ctx.moveTo(x, -1000);
        ctx.lineTo(x, 1000);
        ctx.stroke();
      }
      for (let y = -1000; y <= 1000; y += gridSize) {
        ctx.beginPath();
        ctx.moveTo(-1000, y);
        ctx.lineTo(1000, y);
        ctx.stroke();
      }

      // 2. Draw Distance Radar Rings
      [100, 250, 450].forEach(r => {
        ctx.beginPath();
        ctx.arc(0, 0, r, 0, Math.PI * 2);
        ctx.strokeStyle = "rgba(56, 189, 248, 0.12)";
        ctx.setLineDash([4, 6]);
        ctx.stroke();
        ctx.setLineDash([]);
      });

      // 3. Draw Racetrack (Road Surface & Curbs)
      const pts = mapWaypoints[currentMapIdx];
      
      // Outer track border
      ctx.beginPath();
      for (let t = 0; t <= 1; t += 0.005) {
        const pt = getSplinePoint(pts, t);
        if (t === 0) ctx.moveTo(pt.x, pt.y);
        else ctx.lineTo(pt.x, pt.y);
      }
      ctx.closePath();
      ctx.lineWidth = 28;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";
      ctx.strokeStyle = "rgba(30, 41, 59, 0.85)";
      ctx.stroke();

      // Inner glowing racing line
      ctx.lineWidth = 6;
      ctx.strokeStyle = "#0284c7";
      ctx.shadowColor = "#38bdf8";
      ctx.shadowBlur = 12;
      ctx.stroke();
      ctx.shadowBlur = 0;

      // Draw Apex Waypoint dots
      pts.forEach((wp, idx) => {
        ctx.beginPath();
        ctx.arc(wp.x, wp.y, 4, 0, Math.PI * 2);
        ctx.fillStyle = "#eab308";
        ctx.fill();
        ctx.fillStyle = "rgba(255,255,255,0.4)";
        ctx.font = "10px sans-serif";
        ctx.fillText("WP " + (idx + 1), wp.x + 8, wp.y + 4);
      });

      // 4. Draw Opponents
      opponents.forEach(op => {
        ctx.save();
        ctx.translate(op.x, op.y);
        ctx.rotate(-op.yaw * Math.PI / 180);

        // Arrow
        ctx.beginPath();
        ctx.moveTo(0, -9);
        ctx.lineTo(6, 7);
        ctx.lineTo(0, 4);
        ctx.lineTo(-6, 7);
        ctx.closePath();
        ctx.fillStyle = op.color;
        ctx.shadowColor = op.color;
        ctx.shadowBlur = 10;
        ctx.fill();
        ctx.shadowBlur = 0;

        ctx.rotate(op.yaw * Math.PI / 180);
        ctx.fillStyle = "#f8fafc";
        ctx.font = "bold 10px sans-serif";
        ctx.textAlign = "center";
        ctx.fillText(op.name, 0, -14);
        ctx.restore();
      });

      // 5. Draw Player (You)
      ctx.save();
      ctx.translate(player.x, player.y);

      // Pulsing Radar Ring
      const pulseR = 14 + Math.sin(performance.now() * 0.006) * 4;
      ctx.beginPath();
      ctx.arc(0, 0, pulseR, 0, Math.PI * 2);
      ctx.strokeStyle = "rgba(56, 189, 248, 0.4)";
      ctx.lineWidth = 1.5;
      ctx.stroke();

      ctx.rotate(-player.yaw * Math.PI / 180);

      // Player Arrow Kart
      ctx.beginPath();
      ctx.moveTo(0, -12);
      ctx.lineTo(8, 9);
      ctx.lineTo(0, 5);
      ctx.lineTo(-8, 9);
      ctx.closePath();
      ctx.fillStyle = "#38bdf8";
      ctx.shadowColor = "#38bdf8";
      ctx.shadowBlur = 16;
      ctx.fill();
      ctx.strokeStyle = "#ffffff";
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ctx.shadowBlur = 0;

      // Label
      ctx.rotate(player.yaw * Math.PI / 180);
      ctx.fillStyle = "#38bdf8";
      ctx.font = "bold 11px sans-serif";
      ctx.textAlign = "center";
      ctx.fillText("BẠN (YOU)", 0, -18);

      ctx.restore();
      ctx.restore();
    }

    requestAnimationFrame(animate);
  </script>
</body>
</html>

)RAW_RADAR_HTML";
