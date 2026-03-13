const Module = require('module');
process.stderr.write('[ui-schema-hotfix] loaded\n');

function toUid() {
  return `auto_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

function sanitizeNode(node) {
  if (!node || typeof node !== 'object' || Array.isArray(node)) {
    return {
      type: 'void',
      'x-uid': toUid(),
      name: 'node',
    };
  }

  const out = { ...node };

  if (!out.type) out.type = 'void';
  if (!out['x-uid']) out['x-uid'] = toUid();
  if (!out.name && typeof out.title === 'string') out.name = out.title.replace(/\s+/g, '_').toLowerCase();
  if (!out.name) out.name = out['x-uid'];

  if (out.properties && typeof out.properties === 'object' && !Array.isArray(out.properties)) {
    const props = {};
    Object.entries(out.properties).forEach(([k, v]) => {
      if (v && typeof v === 'object') {
        const child = sanitizeNode(v);
        if (!child.name) child.name = k;
        props[k] = child;
      }
    });
    out.properties = props;
  }

  return out;
}

function patchRepo(repoClass) {
  if (!repoClass || !repoClass.prototype) return;
  if (repoClass.prototype.__uiSchemaHotfixPatched) return;
  repoClass.prototype.__uiSchemaHotfixPatched = true;
  process.stderr.write('[ui-schema-hotfix] repository patched\n');

  if (typeof repoClass.prototype.schemaToSingleNodes === 'function') {
    const original = repoClass.prototype.schemaToSingleNodes;
    repoClass.prototype.schemaToSingleNodes = function patchedSchemaToSingleNodes(schema, ...rest) {
      const safeSchema = sanitizeNode(schema);
      return original.call(this, safeSchema, ...rest);
    };
  }

  if (typeof repoClass.prototype.patch === 'function') {
    const original = repoClass.prototype.patch;
    repoClass.prototype.patch = async function patchedPatch(...args) {
      try {
        return await original.apply(this, args);
      } catch (err) {
        const msg = String((err && err.message) || err || '');
        if (msg.includes("reading 'x-uid'")) return;
        throw err;
      }
    };
  }
}

function patchModuleExports(exportsValue) {
  if (!exportsValue) return;
  const candidateClasses = [];
  if (typeof exportsValue === 'function') candidateClasses.push(exportsValue);
  if (exportsValue.default && typeof exportsValue.default === 'function') candidateClasses.push(exportsValue.default);
  Object.values(exportsValue).forEach((v) => {
    if (typeof v === 'function') candidateClasses.push(v);
  });

  candidateClasses.forEach((cls) => {
    if (!cls || !cls.prototype) return;
    if (typeof cls.prototype.insertAdjacent === 'function' || typeof cls.prototype.schemaToSingleNodes === 'function') {
      patchRepo(cls);
    }
  });
}

const originalLoad = Module._load;
Module._load = function patchedLoad(request, parent, isMain) {
  const loaded = originalLoad.apply(this, arguments);
  if (typeof request === 'string' && request.includes('plugin-ui-schema-storage') && request.includes('repository')) {
    patchModuleExports(loaded);
  }
  return loaded;
};
