const wast2wasm = require('wast2wasm');
const fs = require("fs");

async function convert(wasmTextCode, opts) {
  const wasm = await wast2wasm(wasmTextCode, true);
//   console.log(wasm.log);
//   console.log(wasm.buffer);
  return wasm.buffer;
}
async function run(uint8array) {
    const wasm = await WebAssembly.instantiate(uint8array);

    const result = wasm.instance.exports._start();
    // if (true) {
    //     const memory = new Uint8Array(wasm.instance.exports.memory.buffer);
    //     console.log(memory);
    // }
    return result;
}

async function main() {
    const filename = "a.wat";
    const wast = fs.readFileSync(filename,'utf8').replace(/\r\n/g,"\n");
    const wasm = await convert(wast);
    const res = await run(wasm);
    
    console.log(res);
}

main();