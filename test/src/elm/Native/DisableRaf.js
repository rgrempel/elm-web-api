// This is a testing hack to artificially disable window.requestAnimationFrame

window.saveAnimationFrame = window.requestAnimationFrame;
window.requestAnimationFrame = null;
