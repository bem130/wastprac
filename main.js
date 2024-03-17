const fs = require("fs");
const wabt = require("wabt");
const process = require("process");

const inputWat = process.argv[2];

wabt().then(async function(wabt) {
    const wasmModule = wabt.parseWat(inputWat, fs.readFileSync(inputWat, "utf8"));
    const { buffer } = wasmModule.toBinary({});
    WebAssembly.instantiate(buffer,wasi.importObject).then(res=>{wasi.wasmInstance=res.instance;wasi.wasmInstance.exports._start()}).catch((err)=>{console.error(err);});
});

const wasi = {
    wasmInstance: null,
    importObject: {
        wasi_unstable: {
            fd_write: wasi_fd_write,
            proc_exit: () => {},
        }
    },
}

function wasi_fd_write(fd,iovs,iovsLen,nwritten) {
    const memory = wasi.wasmInstance.exports.memory.buffer;
    const view = new DataView(memory);
    const sizeList = Array.from(Array(iovsLen), (v, i) => {
        const ptr = iovs+i*8;
        const buf = new Uint8Array(memory,view.getUint32(ptr,true),view.getUint32(ptr+4,true));
        const msg = new TextDecoder("utf-8").decode(buf);
        process.stdout.write(msg);
        return buf.byteLength;
    });
    const totalSize = sizeList.reduce((acc,v)=>acc+v);
    view.setUint32(nwritten,totalSize,true);
    return 0;
}