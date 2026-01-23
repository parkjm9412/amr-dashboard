const { contextBridge } = require("electron");

contextBridge.exposeInMainWorld("appInfo", {
  electron: process.versions.electron,
});
