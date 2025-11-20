<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TradePort - EA Converter</title>
    <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .glass-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.1); }
        .gradient-bg { background: linear-gradient(135deg, #262626 0%, #404040 50%, #525252 100%); }
    </style>
</head>
<body class="gradient-bg text-white min-h-screen font-sans p-6">
    <div id="root"></div>

    <script type="text/babel">
        const { useState } = React;

        function TradePort() {
            const [eaFile, setEaFile] = useState(null);
            const [logs, setLogs] = useState([]);
            const [hosting, setHosting] = useState(false);
            const [conversionStatus, setConversionStatus] = useState('idle');

            function handleFileChange(e) {
                const file = e.target.files[0];
                setEaFile(file || null);
                if (file) addLog(`Selected EA: ${file.name}`);
            }

            function addLog(text) {
                setLogs(l => [{ ts: new Date().toLocaleString(), text }, ...l].slice(0, 50));
            }

            function mockConvert() {
                if (!eaFile) {
                    addLog('No EA selected.');
                    return;
                }
                setConversionStatus('running');
                addLog('Conversion started... (mock)');
                setTimeout(() => {
                    setConversionStatus('success');
                    addLog('Conversion finished — package ready (mock).');
                }, 1400);
            }

            function toggleHosting() {
                if (!hosting) {
                    if (!eaFile) { addLog('Cannot start hosting without an EA file.'); return; }
                    setHosting(true);
                    addLog('Hosting started (mock).');
                } else {
                    setHosting(false);
                    addLog('Hosting stopped.');
                }
            }

            return (
                <div className="min-h-screen">
                    <header className="max-w-6xl mx-auto flex items-center justify-between py-6">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-white/10 to-white/6 flex items-center justify-center border border-white/10">
                                <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
                                    <path d="M3 12h18" stroke="white" strokeWidth="1.5" strokeLinecap="round"/>
                                    <path d="M12 3v18" stroke="white" strokeWidth="1.5" strokeLinecap="round"/>
                                </svg>
                            </div>
                            <div>
                                <h1 className="text-2xl font-semibold">TradePort</h1>
                                <p className="text-sm text-white/70">EA Host · Converter · Mobile-ready dashboard</p>
                            </div>
                        </div>
                        <nav className="flex items-center gap-4">
                            <button className="px-4 py-2 rounded-md bg-white/6 border border-white/10">Docs</button>
                            <button className="px-4 py-2 rounded-md bg-white/6 border border-white/10">Support</button>
                            <div className="px-4 py-2 rounded-md bg-gradient-to-r from-white/6 to-white/4 text-black font-medium">Free</div>
                        </nav>
                    </header>

                    <main className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-6">
                        <section className="md:col-span-1 glass-card rounded-2xl p-5">
                            <h2 className="text-lg font-semibold mb-3">Upload EA</h2>
                            <p className="text-sm text-white/70 mb-4">Drag your .mq5 / .ex5 / .mq4 file here</p>

                            <label className="block">
                                <input type="file" accept=".mq5,.mq4,.ex5,.zip" onChange={handleFileChange} className="hidden" id="ea-upload" />
                                <div className="cursor-pointer rounded-lg border-2 border-dashed border-white/10 p-6 text-center hover:bg-white/6">
                                    <div className="text-sm text-white/70">Click to select or drop file</div>
                                    <div className="mt-3 text-xs text-white/60">Supported: .mq5, .mq4, .ex5, .zip</div>
                                </div>
                            </label>

                            <div className="mt-4 flex gap-2">
                                <button onClick={mockConvert} className="flex-1 rounded-md py-2 bg-gradient-to-r from-white/6 to-white/4 text-black font-semibold">Convert (mock)</button>
                                <button onClick={toggleHosting} className="rounded-md py-2 px-4 bg-white/6 border border-white/10">{hosting ? 'Stop' : 'Host'}</button>
                            </div>

                            <div className="mt-4 text-sm">
                                <div className="mb-2">Conversion status:</div>
                                <div className="rounded-md bg-black/40 p-3 text-xs">
                                    {conversionStatus === 'idle' && <span className="text-white/70">Idle</span>}
                                    {conversionStatus === 'running' && <span>Running...</span>}
                                    {conversionStatus === 'success' && <span className="text-green-300">Success — package ready</span>}
                                </div>
                            </div>
                        </section>

                        <section className="md:col-span-2 glass-card rounded-2xl p-6">
                            <div className="flex items-start justify-between">
                                <div>
                                    <h2 className="text-lg font-semibold">Dashboard</h2>
                                    <p className="text-sm text-white/70">Live status & logs</p>
                                </div>
                                <div className="text-sm text-white/60">User: <span className="font-medium">demo@tradeport.local</span></div>
                            </div>

                            <div className="mt-5 grid grid-cols-1 lg:grid-cols-3 gap-4">
                                <div className="p-4 rounded-xl bg-black/40 border border-white/6">
                                    <div className="text-xs text-white/60 mb-2">Hosting</div>
                                    <div className="text-2xl font-bold">{hosting ? 'Online' : 'Offline'}</div>
                                    <div className="text-sm text-white/70 mt-2">Instances: 1 (mock)</div>
                                </div>
                                <div className="p-4 rounded-xl bg-black/40 border border-white/6">
                                    <div className="text-xs text-white/60 mb-2">Active Strategy</div>
                                    <div className="text-2xl font-bold">Scalper X</div>
                                    <div className="text-sm text-white/70 mt-2">Mode: Demo</div>
                                </div>
                                <div className="p-4 rounded-xl bg-black/40 border border-white/6">
                                    <div className="text-xs text-white/60 mb-2">Mobile Sync</div>
                                    <div className="text-2xl font-bold">Connected</div>
                                    <div className="text-sm text-white/70 mt-2">Last ping: {new Date().toLocaleTimeString()}</div>
                                </div>
                            </div>

                            <div className="mt-6">
                                <h3 className="text-sm font-semibold mb-2">Logs</h3>
                                <div className="h-40 overflow-y-auto rounded-md bg-black/30 p-3 text-xs border border-white/6">
                                    {logs.length === 0 && <div className="text-white/60">No logs yet</div>}
                                    {logs.map((l, i) => (
                                        <div key={i} className="mb-2">
                                            <div className="text-xs text-white/60">{l.ts}</div>
                                            <div className="text-sm">{l.text}</div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </section>
                    </main>
                </div>
            );
        }

        const root = ReactDOM.createRoot(document.getElementById('root'));
        root.render(<TradePort />);
    </script>
</body>
</html>
