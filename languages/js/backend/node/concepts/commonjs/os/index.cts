import type * as OS from "node:os";

const os = require("node:os");

type NetworkData = {
  interface: string;
  mask: string;
  ipFamily: string;
  ipAddress: string;
  mac: string;
};

function getNetworkData(): NetworkData[] {
  const interfaces: Record<string, OS.NetworkInterfaceInfo[]> =
    os.networkInterfaces();

  return Object.entries(interfaces).flatMap(([name, addresses]) =>
    (addresses ?? [])
      .filter(
        (networkInterface) =>
          !networkInterface.internal && networkInterface.family === "IPv4",
      )
      .map((networkInterface) => ({
        interface: name,
        ipAddress: networkInterface.address,
        mask: networkInterface.netmask,
        ipFamily: String(networkInterface.family),
        mac: networkInterface.mac,
      })),
  );
}

function getMemoryData() {
  const totalBytes = os.totalmem();
  const freeBytes = os.freemem();
  const usedBytes = totalBytes - freeBytes;

  const totalMem = Number((totalBytes / 1024 ** 3).toFixed(2));
  const freeMem = Number((freeBytes / 1024 ** 3).toFixed(2));
  const usedMem = Number((usedBytes / 1024 ** 3).toFixed(2));
  const usagePercent = `${((usedBytes / totalBytes) * 100).toFixed(2)}%`;

  return {
    total: `${totalMem} GB`,
    free: `${freeMem} GB`,
    used: `${usedMem} GB`,
    usagePercent,
  };
}

function getUptime() {
  const totalSeconds = Math.floor(os.uptime());

  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  return `${hours}h ${minutes}m ${seconds}s`;
}

function getSystemData() {
  const cpus = os.cpus();

  if (!cpus.length) {
    throw new Error("No CPU information available");
  }

  const networkData = getNetworkData();

  const systemData = {
    platform: os.type(),
    architecture: os.arch(),
    version: os.release(),
    uptime: getUptime(),
    cpu: {
      cores: cpus.length,
      model: cpus[0].model,
      speed: cpus[0].speed ? `${cpus[0].speed / 1000} GHz` : "Unknown",
    },
    memory: getMemoryData(),
    network: networkData,
  };

  return systemData;
}

console.log(getSystemData());

setInterval(
  () => {
    console.clear();
    console.log(getSystemData());
  },
  30 * 60 * 1000,
);