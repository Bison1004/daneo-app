const memoryRepository = require("./lingoloopMemoryRepository");
const mysqlRepository = require("./lingoloopMysqlRepository");

const storageMode = String(process.env.LINGOLOOP_STORAGE || "memory").trim().toLowerCase();

function getRepository() {
  if (storageMode === "mysql") {
    return mysqlRepository;
  }
  return memoryRepository;
}

module.exports = getRepository();
