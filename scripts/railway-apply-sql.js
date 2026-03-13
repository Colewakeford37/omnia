const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

function getPgClient() {
  try {
    return require('pg').Client;
  } catch (error) {
    const Module = require('module');

    const globalCandidates = [];

    if (process.env.APPDATA) {
      globalCandidates.push(path.join(process.env.APPDATA, 'npm', 'node_modules'));
    }

    if (process.env.NPM_CONFIG_PREFIX) {
      globalCandidates.push(path.join(process.env.NPM_CONFIG_PREFIX, 'node_modules'));
    }

    const nodePath = [process.env.NODE_PATH, ...globalCandidates].filter(Boolean).join(path.delimiter);
    if (nodePath) {
      process.env.NODE_PATH = nodePath;
      Module._initPaths();
      return require('pg').Client;
    }

    throw error;
  }
}

const Client = getPgClient();

function getArg(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1) return null;
  return process.argv[index + 1] ?? null;
}

function getRailwayService() {
  return getArg('--railway-service') || getArg('--service') || getArg('-s');
}

function getRailwayEnvironment() {
  return getArg('--railway-environment') || getArg('--environment') || getArg('-e');
}

function getInspectTable() {
  return getArg('--inspect');
}

function getInspectSchemaTable() {
  return getArg('--inspect-schema');
}

function getDumpCollectionKey() {
  return getArg('--dump-collection');
}

function getDumpFieldsCollection() {
  return getArg('--dump-fields');
}

function getListCollectionsPrefix() {
  return getArg('--list-collections-prefix');
}

function getListUiSchemasPrefix() {
  return getArg('--list-uischemas-prefix');
}

function getQuery() {
  return getArg('--query') || getArg('-q');
}

function getVerify() {
  return process.argv.includes('--verify');
}

function getCounts() {
  return process.argv.includes('--counts');
}

function getSeed() {
  return process.argv.includes('--seed') || process.argv.includes('--seed-extensive');
}

function getSeedCount() {
  const raw = getArg('--seed-count') || getArg('--count');
  const parsed = Number(raw || 150);
  if (!Number.isFinite(parsed)) return 150;
  return Math.max(100, Math.min(200, Math.floor(parsed)));
}

function getSeedCity() {
  return getArg('--seed-city') || 'Midrand';
}

function getListDesktopRoutes() {
  return process.argv.includes('--list-desktop-routes');
}

function getEnsureCrmRoutes() {
  return process.argv.includes('--ensure-crm-routes');
}

function getListRoutePermissions() {
  return process.argv.includes('--list-route-permissions');
}

function getRouteDiagnostics() {
  return process.argv.includes('--route-diagnostics');
}

function getFixCrmRouteVisibility() {
  return process.argv.includes('--fix-crm-route-visibility');
}

function getListUiSchemas() {
  return process.argv.includes('--list-uischemas');
}

function getUiSchemasLike() {
  return getArg('--uischemas-like') || '';
}

function getEnsureCrmPageSchemas() {
  return process.argv.includes('--ensure-crm-page-schemas');
}

function getUiSchemasContains() {
  return getArg('--uischemas-contains') || '';
}

function getDumpUiSchemaUid() {
  return getArg('--dump-uischema');
}

function getListTablesLike() {
  return getArg('--list-tables-like');
}

function getUiSchemaPathDiagnostics() {
  return process.argv.includes('--uischema-path-diagnostics');
}

function getDumpUiSchemaTree() {
  return getArg('--dump-uischema-tree');
}

function getEnsureCrmPageTreeSchemas() {
  return process.argv.includes('--ensure-crm-page-tree-schemas');
}

function getSqlPath() {
  const fromFlag = getArg('--file') || getArg('-f');
  const positional = process.argv.slice(2).find((v) => !v.startsWith('-'));
  const candidate = fromFlag || positional;

  if (!candidate) {
    console.error('Usage: node scripts/railway-apply-sql.js --file <path-to-sql>');
    process.exit(1);
  }

  const rootDir = path.resolve(__dirname, '..');
  return path.isAbsolute(candidate) ? candidate : path.resolve(rootDir, candidate);
}

function splitSqlStatements(sql) {
  const statements = [];
  let current = '';

  let inSingle = false;
  let inDouble = false;
  let dollarTag = null;

  function flush() {
    const trimmed = current.trim();
    if (trimmed) statements.push(trimmed);
    current = '';
  }

  for (let i = 0; i < sql.length; i += 1) {
    const ch = sql[i];
    const next = sql[i + 1];

    if (dollarTag) {
      if (sql.startsWith(dollarTag, i)) {
        current += dollarTag;
        i += dollarTag.length - 1;
        dollarTag = null;
        continue;
      }
      current += ch;
      continue;
    }

    if (inSingle) {
      current += ch;
      if (ch === "'" && next === "'") {
        current += next;
        i += 1;
        continue;
      }
      if (ch === "'") inSingle = false;
      continue;
    }

    if (inDouble) {
      current += ch;
      if (ch === '"') inDouble = false;
      continue;
    }

    if (ch === "'") {
      inSingle = true;
      current += ch;
      continue;
    }

    if (ch === '"') {
      inDouble = true;
      current += ch;
      continue;
    }

    if (ch === '$') {
      const match = sql.slice(i).match(/^\$[A-Za-z0-9_]*\$/);
      if (match) {
        dollarTag = match[0];
        current += dollarTag;
        i += dollarTag.length - 1;
        continue;
      }
    }

    if (ch === ';') {
      flush();
      continue;
    }

    current += ch;
  }

  flush();
  return statements;
}

function getConnectionConfig(env) {
  const urlVars = [
    'DATABASE_PUBLIC_URL',
    'POSTGRES_PUBLIC_URL',
    'POSTGRESQL_PUBLIC_URL',
    'DATABASE_URL',
    'POSTGRES_URL',
    'POSTGRESQL_URL',
    'PGURL',
    'POSTGRES_CONNECTION_STRING',
  ];
  for (const key of urlVars) {
    const value = env[key];
    if (typeof value === 'string' && value.trim()) {
      if (value.includes('.railway.internal')) continue;
      return { connectionString: value, ssl: { rejectUnauthorized: false } };
    }
  }

  const host = env.PGHOST || env.POSTGRES_HOST;
  const port = Number(env.PGPORT || env.POSTGRES_PORT || 5432);
  const database = env.PGDATABASE || env.POSTGRES_DB;
  const user = env.PGUSER || env.POSTGRES_USER;
  const password = env.PGPASSWORD || env.POSTGRES_PASSWORD;

  if (!host || !database || !user || !password) {
    console.error('Missing Postgres connection environment variables. Expected DATABASE_URL or PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD.');
    process.exit(1);
  }

  return {
    host,
    port,
    database,
    user,
    password,
    ssl: { rejectUnauthorized: false },
  };
}

function safeDescribeConnection(config) {
  if (config.connectionString) {
    try {
      const url = new URL(config.connectionString);
      return `${url.protocol}//${url.username || 'user'}@${url.hostname}:${url.port || '5432'}${url.pathname}`;
    } catch {
      return 'postgres://<redacted>';
    }
  }

  return `postgres://${config.user}@${config.host}:${config.port}/${config.database}`;
}

async function querySafe(client, text) {
  try {
    return await client.query(text);
  } catch (error) {
    return { error };
  }
}

function toEnvMap(parsed) {
  if (!parsed) return {};
  if (Array.isArray(parsed)) {
    return parsed.reduce((acc, item) => {
      if (item && typeof item.name === 'string') acc[item.name] = item.value;
      return acc;
    }, {});
  }

  if (Array.isArray(parsed.variables)) {
    return toEnvMap(parsed.variables);
  }

  if (typeof parsed === 'object') {
    if (typeof parsed.name === 'string' && 'value' in parsed) {
      return { [parsed.name]: parsed.value };
    }

    const looksLikeMap = Object.values(parsed).every(
      (v) => typeof v === 'string' || v === null || typeof v === 'undefined',
    );
    if (looksLikeMap) return parsed;
  }

  return {};
}

async function getRailwayVariables({ service, environment }) {
  const railwayCliCandidates = [
    process.env.RAILWAY_CLI_JS,
    process.env.APPDATA
      ? path.join(process.env.APPDATA, 'npm', 'node_modules', '@railway', 'cli', 'bin', 'railway.js')
      : null,
  ].filter(Boolean);

  const railwayCliJs = railwayCliCandidates.find((p) => {
    try {
      return fs.existsSync(p);
    } catch {
      return false;
    }
  });

  return await new Promise((resolve, reject) => {
    const args = ['variable', 'list', '--json', '-s', service];
    if (environment) args.push('-e', environment);

    const child = railwayCliJs
      ? spawn(process.execPath, [railwayCliJs, ...args], { stdio: ['ignore', 'pipe', 'pipe'] })
      : spawn('railway', args, { stdio: ['ignore', 'pipe', 'pipe'] });
    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (d) => {
      stdout += String(d);
    });
    child.stderr.on('data', (d) => {
      const text = String(d);
      if (text.includes('telemetry') || text.includes('Learn more')) return;
      stderr += text;
    });

    child.on('error', reject);
    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr || `railway variable list exited with code ${code}`));
        return;
      }

      try {
        resolve(toEnvMap(JSON.parse(stdout)));
      } catch {
        reject(new Error('Failed to parse Railway variables JSON output'));
      }
    });
  });
}

async function main() {
  const railwayService = getRailwayService();
  const railwayEnvironment = getRailwayEnvironment();

  const inspectTable = getInspectTable();
  const inspectSchemaTable = getInspectSchemaTable();
  const dumpCollectionKey = getDumpCollectionKey();
  const dumpFieldsCollection = getDumpFieldsCollection();
  const listCollectionsPrefix = getListCollectionsPrefix();
  const listUiSchemasPrefix = getListUiSchemasPrefix();
  const query = getQuery();
  const verify = getVerify();
  const counts = getCounts();
  const seed = getSeed();
  const listDesktopRoutes = getListDesktopRoutes();
  const ensureCrmRoutes = getEnsureCrmRoutes();
  const listRoutePermissions = getListRoutePermissions();
  const routeDiagnostics = getRouteDiagnostics();
  const fixCrmRouteVisibility = getFixCrmRouteVisibility();
  const listUiSchemas = getListUiSchemas();
  const uiSchemasLike = getUiSchemasLike();
  const ensureCrmPageSchemas = getEnsureCrmPageSchemas();
  const uiSchemasContains = getUiSchemasContains();
  const dumpUiSchemaUid = getDumpUiSchemaUid();
  const listTablesLike = getListTablesLike();
  const uiSchemaPathDiagnostics = getUiSchemaPathDiagnostics();
  const dumpUiSchemaTree = getDumpUiSchemaTree();
  const ensureCrmPageTreeSchemas = getEnsureCrmPageTreeSchemas();

  const sqlFilePath =
    inspectTable ||
    inspectSchemaTable ||
    dumpCollectionKey ||
    dumpFieldsCollection ||
    listCollectionsPrefix ||
    listUiSchemasPrefix ||
    query ||
    verify ||
    counts ||
    seed ||
    listDesktopRoutes ||
    ensureCrmRoutes ||
    listRoutePermissions ||
    routeDiagnostics ||
    fixCrmRouteVisibility ||
    listUiSchemas ||
    ensureCrmPageSchemas ||
    dumpUiSchemaUid ||
    listTablesLike ||
    uiSchemaPathDiagnostics ||
    dumpUiSchemaTree ||
    ensureCrmPageTreeSchemas
      ? null
      : getSqlPath();
  const sql = sqlFilePath ? fs.readFileSync(sqlFilePath, 'utf8') : null;

  const env = railwayService
    ? await getRailwayVariables({ service: railwayService, environment: railwayEnvironment })
    : process.env;

  const config = getConnectionConfig(env);
  console.log(`Connecting: ${safeDescribeConnection(config)}`);
  if (sqlFilePath) {
    console.log(`SQL file: ${path.relative(process.cwd(), sqlFilePath)}`);
  }

  const client = new Client(config);
  await client.connect();

  if (
    inspectTable ||
    inspectSchemaTable ||
    dumpCollectionKey ||
    dumpFieldsCollection ||
    listCollectionsPrefix ||
    listUiSchemasPrefix ||
    query ||
    verify ||
    counts ||
    seed ||
    listDesktopRoutes ||
    ensureCrmRoutes ||
    listRoutePermissions ||
    routeDiagnostics ||
    fixCrmRouteVisibility ||
    listUiSchemas ||
    ensureCrmPageSchemas ||
    dumpUiSchemaUid ||
    listTablesLike ||
    uiSchemaPathDiagnostics ||
    dumpUiSchemaTree ||
    ensureCrmPageTreeSchemas
  ) {
    if (listDesktopRoutes) {
      const result = await client.query(
        'SELECT id, "parentId", title, icon, "menuSchemaUid", "schemaUid", type, sort, "hideInMenu" FROM "desktopRoutes" ORDER BY sort NULLS LAST, id LIMIT 300;',
      );
      console.log(JSON.stringify(result.rows, null, 2));
      await client.end();
      return;
    }

    if (listUiSchemas) {
      const like = `%${uiSchemasLike}%`;
      const contains = `%${uiSchemasContains}%`;
      const result = await client.query(
        `SELECT "x-uid" AS xuid, name,
                left(CAST(schema AS text), 160) AS schema_preview
         FROM "uiSchemas"
         WHERE ("x-uid" LIKE $1 OR name LIKE $1)
           AND ($2 = '%%' OR CAST(schema AS text) ILIKE $2)
         ORDER BY "x-uid"
         LIMIT 200;`,
        [like, contains],
      );
      console.log(JSON.stringify(result.rows, null, 2));
      await client.end();
      return;
    }

    if (dumpUiSchemaUid) {
      const result = await client.query(
        'SELECT "x-uid" AS xuid, name, schema FROM "uiSchemas" WHERE "x-uid" = $1 LIMIT 1;',
        [dumpUiSchemaUid],
      );
      console.log(JSON.stringify(result.rows[0] || null, null, 2));
      await client.end();
      return;
    }

    if (listTablesLike) {
      const result = await client.query(
        `SELECT table_name
         FROM information_schema.tables
         WHERE table_schema = 'public'
           AND table_name ILIKE $1
         ORDER BY table_name;`,
        [`%${listTablesLike}%`],
      );
      console.log(JSON.stringify(result.rows, null, 2));
      await client.end();
      return;
    }

    if (uiSchemaPathDiagnostics) {
      const [countRows, sampleRows] = await Promise.all([
        client.query('SELECT COUNT(*)::int AS count FROM "uiSchemaTreePath";'),
        client.query(
          'SELECT ancestor, descendant, depth, async, type, sort FROM "uiSchemaTreePath" ORDER BY ancestor, depth LIMIT 40;',
        ),
      ]);
      console.log(
        JSON.stringify(
          {
            count: countRows.rows[0].count,
            sample: sampleRows.rows,
          },
          null,
          2,
        ),
      );
      await client.end();
      return;
    }

    if (dumpUiSchemaTree) {
      const [paths, nodes] = await Promise.all([
        client.query(
          `SELECT ancestor, descendant, depth, async, type, sort
           FROM "uiSchemaTreePath"
           WHERE ancestor = $1
           ORDER BY depth, descendant
           LIMIT 300;`,
          [dumpUiSchemaTree],
        ),
        client.query(
          `SELECT u."x-uid" AS xuid, u.name, u.schema
           FROM "uiSchemas" u
           WHERE u."x-uid" = $1
              OR u."x-uid" IN (
                SELECT descendant FROM "uiSchemaTreePath" WHERE ancestor = $1
              )
           ORDER BY u."x-uid";`,
          [dumpUiSchemaTree],
        ),
      ]);
      console.log(
        JSON.stringify(
          {
            ancestor: dumpUiSchemaTree,
            pathRows: paths.rows,
            nodeRows: nodes.rows,
          },
          null,
          2,
        ),
      );
      await client.end();
      return;
    }

    if (ensureCrmPageSchemas) {
      const defs = [
        { uid: 'crm-dashboard', title: 'Dashboard', collection: 'crm_leads', columns: ['id', 'full_name', 'status', 'source', 'createdAt'] },
        { uid: 'crm-leads-menu', title: 'Leads', collection: 'crm_leads', columns: ['id', 'full_name', 'email', 'phone', 'status', 'source', 'createdAt'] },
        { uid: 'crm-contacts-menu', title: 'Contacts', collection: 'crm_contacts', columns: ['id', 'full_name', 'email', 'phone', 'company', 'createdAt'] },
        { uid: 'crm-properties-menu', title: 'Properties', collection: 'crm_properties', columns: ['id', 'title', 'suburb', 'city', 'price', 'status', 'listing_date'] },
        { uid: 'crm-deals-menu', title: 'Deals', collection: 'crm_deals', columns: ['id', 'title', 'stage', 'value', 'probability', 'expected_close_date'] },
        { uid: 'crm-suburbs-menu', title: 'Suburbs', collection: 'crm_suburbs', columns: ['id', 'name', 'city', 'province', 'average_price', 'median_price'] },
        { uid: 'crm-fica-menu', title: 'FICA Compliance', collection: 'crm_fica_documents', columns: ['id', 'document_type', 'document_number', 'status', 'created_at'] },
        { uid: 'crm-activities-menu', title: 'Activities', collection: 'crm_activities', columns: ['id', 'activity_type', 'subject', 'status', 'start_date'] },
        { uid: 'crm-email-templates-menu', title: 'Email Templates', collection: 'crm_email_templates', columns: ['id', 'template_name', 'template_type', 'is_active', 'updated_at'] },
      ];

      function makeSchema(def) {
        const cols = {};
        def.columns.forEach((c, idx) => {
          cols[`col_${idx}`] = {
            type: 'void',
            'x-component': 'TableV2.Column',
            'x-component-props': {
              dataIndex: c,
              title: c,
            },
          };
        });

        return {
          type: 'void',
          'x-uid': def.uid,
          'x-component': 'Grid',
          properties: {
            block: {
              type: 'void',
              'x-decorator': 'DataBlockProvider',
              'x-decorator-props': {
                dataSource: 'main',
                collection: def.collection,
                action: 'list',
                resource: def.collection,
              },
              'x-component': 'CardItem',
              properties: {
                table: {
                  type: 'array',
                  'x-component': 'TableV2',
                  'x-component-props': {
                    rowKey: 'id',
                    pagination: {
                      pageSize: 20,
                    },
                  },
                  properties: cols,
                },
              },
            },
          },
        };
      }

      const summary = [];
      for (const def of defs) {
        const schema = makeSchema(def);
        const result = await client.query(
          'UPDATE "uiSchemas" SET schema = $1::json, name = $2 WHERE "x-uid" = $3;',
          [JSON.stringify(schema), def.uid.replace(/-/g, '_'), def.uid],
        );
        summary.push({ uid: def.uid, updated: result.rowCount || 0, collection: def.collection });
      }

      console.log(JSON.stringify({ ensuredCrmPageSchemas: summary }, null, 2));
      await client.end();
      return;
    }

    if (ensureCrmPageTreeSchemas) {
      const defs = [
        { schemaUid: 'crm_dashboard', title: 'Dashboard', collection: 'crm_leads', columns: ['id', 'full_name', 'status', 'source', 'createdAt'] },
        { schemaUid: 'crm_leads_menu', title: 'Leads', collection: 'crm_leads', columns: ['id', 'full_name', 'email', 'phone', 'status', 'source', 'createdAt'] },
        { schemaUid: 'crm_contacts_menu', title: 'Contacts', collection: 'crm_contacts', columns: ['id', 'full_name', 'email', 'phone', 'company', 'createdAt'] },
        { schemaUid: 'crm_properties_menu', title: 'Properties', collection: 'crm_properties', columns: ['id', 'title', 'suburb', 'city', 'price', 'status', 'listing_date'] },
        { schemaUid: 'crm_deals_menu', title: 'Deals', collection: 'crm_deals', columns: ['id', 'title', 'stage', 'value', 'probability', 'expected_close_date'] },
        { schemaUid: 'crm_suburbs_menu', title: 'Suburbs', collection: 'crm_suburbs', columns: ['id', 'name', 'city', 'province', 'average_price', 'median_price'] },
        { schemaUid: 'crm_fica_menu', title: 'FICA Compliance', collection: 'crm_fica_documents', columns: ['id', 'document_type', 'document_number', 'status', 'created_at'] },
        { schemaUid: 'crm_activities_menu', title: 'Activities', collection: 'crm_activities', columns: ['id', 'activity_type', 'subject', 'status', 'start_date'] },
        { schemaUid: 'crm_email_templates_menu', title: 'Email Templates', collection: 'crm_email_templates', columns: ['id', 'template_name', 'template_type', 'is_active', 'updated_at'] },
      ];

      const upserted = [];
      const touched = new Set();
      const pathRows = [];

      for (const def of defs) {
        const root = def.schemaUid;
        const block = `${def.schemaUid}_block`;
        const table = `${def.schemaUid}_table`;
        touched.add(root);
        touched.add(block);
        touched.add(table);

        const colUids = def.columns.map((c, i) => `${def.schemaUid}_col_${i + 1}`);
        colUids.forEach((u) => touched.add(u));

        const rootSchema = {
          type: 'void',
          'x-uid': root,
          title: def.title,
          'x-component': 'Grid',
          properties: {
            block: { 'x-uid': block },
          },
        };
        const blockSchema = {
          type: 'void',
          'x-uid': block,
          'x-decorator': 'DataBlockProvider',
          'x-decorator-props': {
            dataSource: 'main',
            collection: def.collection,
            action: 'list',
            resource: def.collection,
          },
          'x-component': 'CardItem',
          properties: {
            table: { 'x-uid': table },
          },
        };
        const tableProps = {};
        def.columns.forEach((c, i) => {
          tableProps[c] = { 'x-uid': colUids[i] };
        });
        const tableSchema = {
          type: 'array',
          'x-uid': table,
          'x-component': 'TableV2',
          'x-component-props': {
            rowKey: 'id',
            pagination: { pageSize: 20 },
          },
          properties: tableProps,
        };

        const nodeRows = [
          { uid: root, name: root, schema: rootSchema, depthType: 'void' },
          { uid: block, name: null, schema: blockSchema, depthType: 'void' },
          { uid: table, name: null, schema: tableSchema, depthType: 'array' },
        ];
        def.columns.forEach((c, i) => {
          nodeRows.push({
            uid: colUids[i],
            name: null,
            schema: {
              type: 'void',
              'x-uid': colUids[i],
              'x-component': 'TableV2.Column',
              'x-component-props': { dataIndex: c, title: c },
            },
            depthType: 'void',
          });
        });

        for (const n of nodeRows) {
          await client.query(
            `INSERT INTO "uiSchemas" ("x-uid", "name", "schema")
             VALUES ($1, $2, $3::json)
             ON CONFLICT ("x-uid")
             DO UPDATE SET name = EXCLUDED.name, schema = EXCLUDED.schema;`,
            [n.uid, n.name, JSON.stringify(n.schema)],
          );
          upserted.push(n.uid);
        }

        const selfRows = nodeRows.map((n) => [n.uid, n.uid, 0, false, n.depthType, null]);
        pathRows.push(...selfRows);
        pathRows.push([root, block, 1, false, 'void', 1]);
        pathRows.push([root, table, 2, false, 'array', 1]);
        pathRows.push([block, table, 1, false, 'array', 1]);
        def.columns.forEach((_, i) => {
          const col = colUids[i];
          pathRows.push([root, col, 3, false, 'void', i + 1]);
          pathRows.push([block, col, 2, false, 'void', i + 1]);
          pathRows.push([table, col, 1, false, 'void', i + 1]);
        });
      }

      const touchedArray = Array.from(touched);
      await client.query('DELETE FROM "uiSchemaTreePath" WHERE ancestor = ANY($1::varchar[]) OR descendant = ANY($1::varchar[]);', [
        touchedArray,
      ]);
      for (const row of pathRows) {
        await client.query(
          `INSERT INTO "uiSchemaTreePath" ("ancestor", "descendant", "depth", "async", "type", "sort")
           VALUES ($1, $2, $3, $4, $5, $6);`,
          row,
        );
      }

      console.log(
        JSON.stringify(
          {
            ensuredCrmPageTreeSchemas: defs.map((d) => d.schemaUid),
            uiSchemasUpserted: upserted.length,
            uiSchemaPathRowsInserted: pathRows.length,
          },
          null,
          2,
        ),
      );
      await client.end();
      return;
    }

    if (listRoutePermissions) {
      const result = await client.query(
        `SELECT r."roleName", COUNT(*)::int AS count
         FROM "rolesDesktopRoutes" r
         JOIN "desktopRoutes" d ON d.id = r."desktopRouteId"
         WHERE d."menuSchemaUid" LIKE 'crm-%'
         GROUP BY r."roleName"
         ORDER BY r."roleName";`,
      );
      console.log(JSON.stringify(result.rows, null, 2));
      await client.end();
      return;
    }

    if (routeDiagnostics) {
      const [desktopCount, pathCount, roleCount, crmRoutes, crmPaths, permissions] = await Promise.all([
        querySafe(client, 'SELECT COUNT(*)::int AS count FROM "desktopRoutes";'),
        querySafe(client, 'SELECT COUNT(*)::int AS count FROM "main_desktopRoutes_path";'),
        querySafe(client, 'SELECT COUNT(*)::int AS count FROM "rolesDesktopRoutes";'),
        querySafe(
          client,
          `SELECT id, "parentId", title, "menuSchemaUid", "schemaUid", type, sort, hidden, "hideInMenu"
           FROM "desktopRoutes"
           WHERE "menuSchemaUid" LIKE 'crm-%' OR "menuSchemaUid" = 'crm-menu-group'
           ORDER BY sort NULLS LAST, id;`,
        ),
        querySafe(
          client,
          `SELECT p.ancestor, p.descendant, p.depth
           FROM "main_desktopRoutes_path" p
           JOIN "desktopRoutes" d ON d.id = p.descendant
           WHERE d."menuSchemaUid" LIKE 'crm-%' OR d."menuSchemaUid" = 'crm-menu-group'
           ORDER BY p.descendant, p.depth;`,
        ),
        querySafe(
          client,
          `SELECT r."roleName", COUNT(*)::int AS count
           FROM "rolesDesktopRoutes" r
           JOIN "desktopRoutes" d ON d.id = r."desktopRouteId"
           WHERE d."menuSchemaUid" LIKE 'crm-%' OR d."menuSchemaUid" = 'crm-menu-group'
           GROUP BY r."roleName"
           ORDER BY r."roleName";`,
        ),
      ]);

      console.log(
        JSON.stringify(
          {
            desktopRoutesCount: desktopCount.error ? null : desktopCount.rows[0].count,
            desktopRoutesPathCount: pathCount.error ? null : pathCount.rows[0].count,
            rolesDesktopRoutesCount: roleCount.error ? null : roleCount.rows[0].count,
            crmRoutes: crmRoutes.error ? null : crmRoutes.rows,
            crmPaths: crmPaths.error ? null : crmPaths.rows,
            crmRoutePermissions: permissions.error ? null : permissions.rows,
          },
          null,
          2,
        ),
      );
      await client.end();
      return;
    }

    if (fixCrmRouteVisibility) {
      const result = await client.query(
        `UPDATE "desktopRoutes"
         SET "parentId" = NULL, "updatedAt" = NOW()
         WHERE "menuSchemaUid" LIKE 'crm-%';`,
      );
      const routes = await client.query(
        `SELECT id, "parentId", title, "menuSchemaUid", sort
         FROM "desktopRoutes"
         WHERE "menuSchemaUid" LIKE 'crm-%' OR "menuSchemaUid" = 'crm-menu-group'
         ORDER BY sort NULLS LAST, id;`,
      );
      console.log(JSON.stringify({ updatedRows: result.rowCount, routes: routes.rows }, null, 2));
      await client.end();
      return;
    }

    if (ensureCrmRoutes) {
      const rootUid = 'crm-menu-group';
      const menuItems = [
        { uid: 'crm-dashboard', title: 'Dashboard', icon: 'DashboardOutlined', sort: 101 },
        { uid: 'crm-leads-menu', title: 'Leads', icon: 'UserOutlined', sort: 102 },
        { uid: 'crm-contacts-menu', title: 'Contacts', icon: 'TeamOutlined', sort: 103 },
        { uid: 'crm-properties-menu', title: 'Properties', icon: 'HomeOutlined', sort: 104 },
        { uid: 'crm-deals-menu', title: 'Deals', icon: 'DollarOutlined', sort: 105 },
        { uid: 'crm-suburbs-menu', title: 'Suburbs', icon: 'EnvironmentOutlined', sort: 106 },
        { uid: 'crm-fica-menu', title: 'FICA Compliance', icon: 'SafetyOutlined', sort: 107 },
        { uid: 'crm-activities-menu', title: 'Activities', icon: 'CalendarOutlined', sort: 108 },
        { uid: 'crm-email-templates-menu', title: 'Email Templates', icon: 'MailOutlined', sort: 109 },
      ];

      const maxIdResult = await client.query('SELECT COALESCE(MAX(id), 0)::bigint AS max_id FROM "desktopRoutes";');
      let nextId = BigInt(maxIdResult.rows[0].max_id || 0) + 1n;
      const summary = [];

      async function routeByMenuUid(uid) {
        const row = await client.query('SELECT id FROM "desktopRoutes" WHERE "menuSchemaUid" = $1 LIMIT 1;', [uid]);
        return row.rows[0] || null;
      }

      function allocId() {
        const id = nextId;
        nextId += 1n;
        return id.toString();
      }

      let rootRoute = await routeByMenuUid(rootUid);
      if (!rootRoute) {
        const newId = allocId();
        await client.query(
          `INSERT INTO "desktopRoutes" ("id", "title", "icon", "menuSchemaUid", "schemaUid", "tabSchemaName", "type", "sort", "hideInMenu", "enableTabs", "enableHeader", "displayTitle", "hidden", "createdAt", "updatedAt")
           VALUES ($1, $2, $3, $4, $4, $5, $6, $7, FALSE, FALSE, TRUE, TRUE, FALSE, NOW(), NOW());`,
          [newId, 'Real Estate CRM', 'ShopOutlined', rootUid, 'crm_menu_group', 'menu', 100],
        );
        rootRoute = { id: newId };
        summary.push({ route: rootUid, action: 'inserted' });
      } else {
        summary.push({ route: rootUid, action: 'exists' });
      }

      for (const item of menuItems) {
        const exists = await routeByMenuUid(item.uid);
        if (exists) {
          summary.push({ route: item.uid, action: 'exists' });
          continue;
        }

        const newId = allocId();
        await client.query(
          `INSERT INTO "desktopRoutes" ("id", "parentId", "title", "icon", "menuSchemaUid", "schemaUid", "tabSchemaName", "type", "sort", "hideInMenu", "enableTabs", "enableHeader", "displayTitle", "hidden", "createdAt", "updatedAt")
           VALUES ($1, $2, $3, $4, $5, $5, $6, $7, $8, FALSE, FALSE, TRUE, TRUE, FALSE, NOW(), NOW());`,
          [newId, rootRoute.id, item.title, item.icon, item.uid, item.uid.replace(/-/g, '_'), 'menu', item.sort],
        );
        summary.push({ route: item.uid, action: 'inserted' });
      }

      const allRouteRows = await client.query(
        'SELECT id, "menuSchemaUid" FROM "desktopRoutes" WHERE "menuSchemaUid" = ANY($1::text[]) ORDER BY id;',
        [[rootUid, ...menuItems.map((m) => m.uid)]],
      );
      const roleRows = await client.query('SELECT name FROM roles ORDER BY name;');

      for (const role of roleRows.rows) {
        for (const route of allRouteRows.rows) {
          await client.query(
            `INSERT INTO "rolesDesktopRoutes" ("createdAt", "updatedAt", "desktopRouteId", "roleName")
             SELECT NOW(), NOW(), $1, $2::varchar
             WHERE NOT EXISTS (
               SELECT 1 FROM "rolesDesktopRoutes" WHERE "desktopRouteId" = $1 AND "roleName" = $2::varchar
             );`,
            [route.id, role.name],
          );
        }
      }
      summary.push({ routePermissions: 'ensured', roles: roleRows.rows.map((r) => r.name), routes: allRouteRows.rows.length });

      console.log(JSON.stringify({ ensuredRoutes: summary }, null, 2));
      await client.end();
      return;
    }

    if (verify) {
      const info = await client.query(
        'SELECT current_database() AS db, current_schema() AS schema, inet_server_addr() AS server_addr, inet_server_port() AS server_port;',
      );
      const dbs = await client.query('SELECT datname FROM pg_database ORDER BY datname;');
      console.log(JSON.stringify({ connectedTo: info.rows[0], databases: dbs.rows.map((r) => r.datname) }, null, 2));
      await client.end();
      return;
    }

    if (counts) {
      const tables = await client.query(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'crm_%' ORDER BY table_name;",
      );
      const countsByTable = {};
      for (const row of tables.rows) {
        const name = row.table_name;
        const result = await client.query(`SELECT COUNT(*)::bigint AS count FROM \"public\".\"${name}\";`);
        countsByTable[name] = Number(result.rows[0].count);
      }

      const collectionsCount = await querySafe(
        client,
        "SELECT COUNT(*)::bigint AS count FROM collections WHERE name LIKE 'crm_%';",
      );
      const uiSchemasCount = await querySafe(
        client,
        "SELECT COUNT(*)::bigint AS count FROM \"uiSchemas\" WHERE \"x-uid\" LIKE 'crm-%';",
      );

      console.log(
        JSON.stringify(
          {
            crmTables: tables.rows.map((r) => r.table_name),
            rowCounts: countsByTable,
            collectionsCount: collectionsCount.error ? null : Number(collectionsCount.rows[0].count),
            uiSchemasCount: uiSchemasCount.error ? null : Number(uiSchemasCount.rows[0].count),
          },
          null,
          2,
        ),
      );
      await client.end();
      return;
    }

    if (seed) {
      const seedCount = getSeedCount();
      const seedCity = getSeedCity();
      const now = new Date();
      const firstNames = ['Lebo', 'Anele', 'Sipho', 'Naledi', 'Thabo', 'Ayesha', 'Kagiso', 'Zanele', 'Mpho', 'Palesa', 'Nandi', 'Trevor', 'Sibusiso', 'Nomsa', 'Bongani', 'Amahle'];
      const lastNames = ['Nkosi', 'Dlamini', 'Mokoena', 'Naidoo', 'Pillay', 'Botha', 'van Wyk', 'Khumalo', 'Ndlovu', 'Mabena', 'Mthembu', 'Molefe', 'Sithole', 'Pretorius', 'Radebe', 'Mahlangu'];
      const companies = ['Midrand Realty Group', 'Kyalami Estates', 'Blue Hills Developments', 'Carlswald Property Partners', 'Waterfall Property Hub', 'Noordwyk Homes', 'Halfway Gardens Realty', 'Gauteng Property Link'];
      const suburbs = ['Midrand', 'Noordwyk', 'Halfway Gardens', 'Carlswald', 'Vorna Valley', 'Kyalami', 'Blue Hills', 'Crowthorne', 'Summerset', 'Waterfall'];
      const propertyTypes = ['house', 'apartment', 'townhouse', 'commercial', 'land'];
      const listingTypes = ['sale', 'rent'];
      const leadStatuses = ['new', 'contacted', 'qualified', 'lost', 'converted'];
      const ficaStatuses = ['pending', 'verified', 'rejected', 'expired'];
      const dealStages = ['prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost'];
      const trends = ['up', 'stable', 'down'];
      const activityTypes = ['call', 'email', 'meeting', 'note'];
      const activityStatuses = ['pending', 'completed', 'cancelled'];
      const priorities = ['low', 'medium', 'high', 'urgent'];
      const templateTypes = ['welcome', 'follow_up', 'proposal', 'reminder', 'marketing', 'notification'];
      let idCounter = 0n;
      const ids = {
        crm_leads: [],
        crm_contacts: [],
        crm_properties: [],
        crm_deals: [],
      };

      function pick(arr, i, salt = 0) {
        return arr[(i + salt) % arr.length];
      }

      function nextId() {
        idCounter += 1n;
        return (BigInt(Date.now()) * 1000n + idCounter).toString();
      }

      function makePhone(i) {
        const n = String(700000000 + i).slice(-9);
        return `0${n}`;
      }

      function makeIdNumber(i) {
        const yy = String(80 + (i % 20)).slice(-2);
        const mm = String((i % 12) + 1).padStart(2, '0');
        const dd = String((i % 27) + 1).padStart(2, '0');
        const serial = String(1000 + i).slice(-4);
        return `${yy}${mm}${dd}${serial}08${i % 10}`;
      }

      function dateOffset(i, days = 0) {
        return new Date(now.getTime() + (i + days) * 24 * 60 * 60 * 1000);
      }

      function genericByType(col, i) {
        if (col.udt_name === 'bool') return i % 2 === 0;
        if (['int2', 'int4', 'int8'].includes(col.udt_name)) return i + 1;
        if (['numeric', 'float4', 'float8'].includes(col.udt_name)) return Number((1000 + i * 13.7).toFixed(2));
        if (['timestamp', 'timestamptz', 'date'].includes(col.udt_name)) return dateOffset(i);
        if (['json', 'jsonb'].includes(col.udt_name)) return {};
        return `sample_${col.column_name}_${i + 1}`;
      }

      async function getColumns(table) {
        const res = await client.query(
          `SELECT column_name, is_nullable, udt_name, column_default
           FROM information_schema.columns
           WHERE table_schema = 'public' AND table_name = $1
           ORDER BY ordinal_position;`,
          [table],
        );
        return res.rows;
      }

      async function countRows(table) {
        const result = await client.query(`SELECT COUNT(*)::bigint AS count FROM "public"."${table}";`);
        return Number(result.rows[0].count);
      }

      async function loadExistingIds(table) {
        try {
          const result = await client.query(`SELECT id FROM "public"."${table}" WHERE id IS NOT NULL LIMIT 5000;`);
          ids[table] = result.rows.map((r) => String(r.id));
        } catch {
          ids[table] = [];
        }
      }

      function resolveValue(table, col, i) {
        const c = col.column_name;
        const first = pick(firstNames, i);
        const last = pick(lastNames, i, 3);
        const fullName = `${first} ${last}`;
        const suburb = pick(suburbs, i);
        const company = pick(companies, i);
        const email = `${first.toLowerCase()}.${last.toLowerCase().replace(/\s+/g, '')}.${i + 1}@example.co.za`;
        const idNo = makeIdNumber(i);
        const dealId = ids.crm_deals.length ? ids.crm_deals[i % ids.crm_deals.length] : null;
        const leadId = ids.crm_leads.length ? ids.crm_leads[i % ids.crm_leads.length] : null;
        const contactId = ids.crm_contacts.length ? ids.crm_contacts[i % ids.crm_contacts.length] : null;
        const propertyId = ids.crm_properties.length ? ids.crm_properties[i % ids.crm_properties.length] : null;

        if (c === 'id') return nextId();
        if (c === 'createdAt' || c === 'updatedAt' || c === 'created_at' || c === 'updated_at') return dateOffset(i, -15);
        if (c === 'full_name') return fullName;
        if (c === 'first_name') return first;
        if (c === 'last_name') return last;
        if (c === 'email' || c === 'owner_email' || c === 'from_email') return email;
        if (c === 'phone' || c === 'mobile' || c === 'owner_phone') return makePhone(i);
        if (c === 'company') return company;
        if (c === 'city') return seedCity;
        if (c === 'suburb' || c === 'name' || c === 'suburb_name') return suburb;
        if (c === 'province') return 'GP';
        if (c === 'postal_code') return String(1680 + (i % 20));
        if (c === 'country') return 'South Africa';
        if (c === 'address' || c === 'address_line1') return `${100 + (i % 900)} ${suburb} Drive`;
        if (c === 'street_name') return `${suburb} Drive`;
        if (c === 'street_number') return String(100 + (i % 900));
        if (c === 'title') return `Midrand Listing ${i + 1}`;
        if (c === 'description' || c === 'notes' || c === 'won_details') return `Detailed Midrand test record ${i + 1}`;
        if (c === 'job_title') return pick(['Agent', 'Sales Manager', 'Director', 'Owner', 'Broker'], i);
        if (c === 'status') {
          if (table === 'crm_leads') return pick(leadStatuses, i);
          if (table === 'crm_properties') return pick(['available', 'sold', 'pending', 'withdrawn'], i);
          if (table === 'crm_deals') return pick(['pending', 'active', 'closed'], i);
          if (table === 'crm_activities') return pick(activityStatuses, i);
          if (table === 'crm_fica_documents') return pick(['pending', 'verified', 'rejected'], i);
          return pick(leadStatuses, i);
        }
        if (c === 'stage') return pick(dealStages, i);
        if (c === 'source') return pick(['website', 'referral', 'social', 'advertisement', 'walk_in'], i);
        if (c === 'source_detail') return `Campaign ${((i % 8) + 1).toString()}`;
        if (c === 'id_number' || c === 'rsa_id') return idNo;
        if (c === 'tax_number') return `TX${String(10000000 + i)}`;
        if (c === 'property_type') return pick(propertyTypes, i);
        if (c === 'listing_type') return pick(listingTypes, i);
        if (c === 'price' || c === 'value' || c === 'average_price' || c === 'median_price') return 700000 + i * 3500;
        if (c === 'price_display') return `R ${(700000 + i * 3500).toLocaleString('en-ZA')}`;
        if (c === 'bedrooms' || c === 'bedrooms_required') return 1 + (i % 5);
        if (c === 'bathrooms' || c === 'bathrooms_required') return 1 + (i % 4);
        if (c === 'garage' || c === 'parking' || c === 'parking_spaces') return i % 3;
        if (c === 'floor_area' || c === 'land_size' || c === 'erf_size' || c === 'square_meters') return 70 + (i % 400);
        if (c === 'year_built') return 1990 + (i % 35);
        if (c === 'floors' || c === 'living_areas') return 1 + (i % 3);
        if (c === 'probability') return 20 + (i % 80);
        if (c === 'commission_rate') return Number((4 + (i % 3) * 0.5).toFixed(2));
        if (c === 'commission') return Number(((700000 + i * 3500) * 0.05).toFixed(2));
        if (c === 'expected_close_date' || c === 'next_follow_up' || c === 'follow_up_date' || c === 'expiry_date') return dateOffset(i, 30);
        if (c === 'actual_close_date' || c === 'last_contacted' || c === 'last_contact_date' || c === 'verified_at' || c === 'last_used') return dateOffset(i, -3);
        if (c === 'timeline_date' || c === 'listing_date' || c === 'mandate_expiry') return dateOffset(i, 14);
        if (c === 'priority') return pick(priorities, i);
        if (c === 'rating' || c === 'engagement_score') return 1 + (i % 5);
        if (c === 'fica_status') return pick(ficaStatuses, i);
        if (c === 'fica_completed') return i % 3 === 0;
        if (c === 'do_not_call' || c === 'do_not_email' || c === 'pool' || c === 'garden' || c === 'security' || c === 'negotiable' || c === 'is_active') return i % 2 === 0;
        if (c === 'latitude') return -25.99 + ((i % 50) * 0.001);
        if (c === 'longitude') return 28.12 + ((i % 50) * 0.001);
        if (c === 'region') return 'Midrand North';
        if (c === 'price_trend') return pick(trends, i);
        if (c === 'days_on_market') return 10 + (i % 120);
        if (c === 'inventory_count' || c === 'viewings_count' || c === 'inquiries_count' || c === 'property_count' || c === 'usage_count') return 1 + (i % 300);
        if (c === 'activity_type') return pick(activityTypes, i);
        if (c === 'subject') return `Midrand activity ${i + 1}`;
        if (c === 'start_date') return dateOffset(i, -1);
        if (c === 'end_date') return dateOffset(i);
        if (c === 'duration_minutes') return 15 + (i % 90);
        if (c === 'outcome') return pick(['Qualified', 'No answer', 'Follow-up', 'Completed'], i);
        if (c === 'next_action') return 'Schedule follow-up call';
        if (c === 'location') return `${suburb}, ${seedCity}`;
        if (c === 'participants') return `${fullName}; Agent ${pick(firstNames, i, 6)}`;
        if (c === 'attachments' || c === 'images') return JSON.stringify([`https://example.co.za/assets/${table}/${i + 1}.jpg`]);
        if (c === 'virtual_tour_url') return `https://example.co.za/tour/${i + 1}`;
        if (c === 'owner_name' || c === 'from_name') return fullName;
        if (c === 'mandate_type') return pick(['open', 'sole', 'dual'], i);
        if (c === 'deal_ref') return `DEAL-${String(i + 1).padStart(6, '0')}`;
        if (c === 'property_ref') return `PROP-${String(i + 1).padStart(6, '0')}`;
        if (c === 'document_type') return pick(['id_document', 'proof_of_address', 'proof_of_income', 'bank_statement'], i);
        if (c === 'document_number') return `DOC-${String(i + 1).padStart(6, '0')}`;
        if (c === 'file_name' || c === 'original_name') return `midrand-doc-${i + 1}.pdf`;
        if (c === 'file_path') return `/uploads/midrand/${table}/${i + 1}.pdf`;
        if (c === 'mime_type') return 'application/pdf';
        if (c === 'file_size') return 120000 + i * 127;
        if (c === 'template_name') return `Midrand Template ${i + 1}`;
        if (c === 'template_type') return pick(templateTypes, i);
        if (c === 'body_text') return `Hi {{first_name}}, this is Midrand template ${i + 1}.`;
        if (c === 'body_html') return `<p>Hi {{first_name}}, this is Midrand template ${i + 1}.</p>`;
        if (c === 'cc_emails' || c === 'bcc_emails') return `ops+${i + 1}@example.co.za`;
        if (c === 'variables') return JSON.stringify({ city: seedCity, suburb, index: i + 1 });
        if (c === 'assigned_to' || c === 'created_by' || c === 'verified_by') return 1;

        if (c === 'lead_id') return leadId;
        if (c === 'contact_id') return contactId;
        if (c === 'property_id') return propertyId;
        if (c === 'deal_id') return dealId;

        if (['fica_documents', 'fica_checklist'].includes(c)) return {};
        return undefined;
      }

      async function insertMany(table, targetCount) {
        const columns = await getColumns(table);
        const existing = await countRows(table);
        const toInsert = Math.max(0, targetCount - existing);
        let inserted = 0;

        for (let i = 0; i < toInsert; i += 1) {
          const rowIndex = existing + i;
          const row = {};

          for (const col of columns) {
            const value = resolveValue(table, col, rowIndex);
            if (value !== undefined) {
              row[col.column_name] = value;
              continue;
            }

            if (col.is_nullable === 'NO' && !col.column_default) {
              row[col.column_name] = genericByType(col, rowIndex);
            }
          }

          if (!Object.keys(row).length) continue;

          const colNames = Object.keys(row);
          const values = colNames.map((c) => row[c]);
          const placeholders = colNames.map((_, idx) => `$${idx + 1}`).join(', ');
          const sqlInsert = `INSERT INTO "public"."${table}" (${colNames.map((c) => `"${c}"`).join(', ')}) VALUES (${placeholders});`;
          await client.query(sqlInsert, values);
          inserted += 1;
          if (row.id && ids[table]) ids[table].push(String(row.id));
        }

        return { table, existing, inserted, final: existing + inserted, targetCount };
      }

      const tablesResult = await client.query(
        "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE 'crm_%' ORDER BY table_name;",
      );
      const crmTables = tablesResult.rows.map((r) => r.table_name);

      for (const t of ['crm_leads', 'crm_contacts', 'crm_properties', 'crm_deals']) {
        if (crmTables.includes(t)) {
          await loadExistingIds(t);
        }
      }

      const seedOrder = [
        'crm_suburbs',
        'crm_leads',
        'crm_contacts',
        'crm_properties',
        'crm_deals',
        'crm_activities',
        'crm_fica_documents',
        'crm_email_templates',
      ].filter((t) => crmTables.includes(t));

      const results = [];
      for (const table of seedOrder) {
        const result = await insertMany(table, seedCount);
        results.push(result);
      }

      console.log(
        JSON.stringify(
          {
            seedCity,
            seedCount,
            tables: results,
          },
          null,
          2,
        ),
      );
      await client.end();
      return;
    }

    if (query) {
      const result = await client.query(query);
      console.log(JSON.stringify(result.rows, null, 2));
      await client.end();
      return;
    }

    if (listUiSchemasPrefix) {
      const rows = await client.query(
        'SELECT "x-uid" as xuid, name FROM "uiSchemas" WHERE "x-uid" LIKE $1 ORDER BY "x-uid";',
        [`${listUiSchemasPrefix}%`],
      );
      console.log(JSON.stringify(rows.rows, null, 2));
      await client.end();
      return;
    }

    if (listCollectionsPrefix) {
      const rows = await client.query(
        'SELECT key, name, title, sort FROM "collections" WHERE name LIKE $1 ORDER BY sort NULLS LAST, key;',
        [`${listCollectionsPrefix}%`],
      );
      console.log(JSON.stringify(rows.rows, null, 2));
      await client.end();
      return;
    }

    if (dumpCollectionKey) {
      const row = await client.query('SELECT * FROM "collections" WHERE key = $1 LIMIT 1;', [dumpCollectionKey]);
      console.log(JSON.stringify(row.rows[0] || null, null, 2));
      await client.end();
      return;
    }

    if (dumpFieldsCollection) {
      const rows = await client.query(
        'SELECT key, name, type, interface, options, sort FROM "fields" WHERE "collectionName" = $1 ORDER BY sort NULLS LAST, key;',
        [dumpFieldsCollection],
      );
      console.log(JSON.stringify(rows.rows, null, 2));
      await client.end();
      return;
    }

    if (inspectSchemaTable) {
      const result = await client.query(
        'SELECT column_name, is_nullable, udt_name FROM information_schema.columns WHERE table_name = $1 ORDER BY ordinal_position;',
        [inspectSchemaTable],
      );
      console.log(
        `${inspectSchemaTable} schema: ${result.rows
          .map((r) => `${r.column_name}(${r.udt_name},${r.is_nullable})`)
          .join(', ')}`,
      );
    } else {
      const allow = new Set(['collections', 'fields', 'uiSchemas']);
      const target = inspectTable;
      if (!allow.has(target)) {
        console.error(`Unsupported inspect table: ${target}`);
        process.exit(1);
      }

      const result = await client.query(`SELECT * FROM "${inspectTable}" LIMIT 0;`);
      console.log(`${inspectTable} columns: ${result.fields.map((f) => f.name).join(', ')}`);
    }

    await client.end();
    return;
  }

  try {
    await client.query("SET statement_timeout = '0'");

    const statements = splitSqlStatements(sql);
    for (let idx = 0; idx < statements.length; idx += 1) {
      try {
        await client.query(statements[idx]);
      } catch (error) {
        const preview = statements[idx].replace(/\s+/g, ' ').slice(0, 180);
        error.statementIndex = idx;
        error.statementPreview = preview;
        throw error;
      }
    }
  } catch (error) {
    const extra =
      typeof error?.statementIndex === 'number'
        ? ` (statement ${error.statementIndex + 1}) ${error.statementPreview}`
        : '';
    console.error('SQL apply failed:', `${error?.message || error}${extra}`);
    process.exitCode = 1;
  }

  const tables = await querySafe(
    client,
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'crm_%' ORDER BY table_name;",
  );

  if (!tables.error) {
    console.log(`CRM tables found: ${tables.rows.length}`);
    if (tables.rows.length) {
      console.log(tables.rows.map((r) => r.table_name).join(', '));
    }
  }

  const collections = await querySafe(client, "SELECT name FROM collections WHERE name LIKE 'crm_%' ORDER BY name;");
  if (!collections.error) {
    console.log(`NocoBase collections found: ${collections.rows.length}`);
    if (collections.rows.length) {
      console.log(collections.rows.map((r) => r.name).join(', '));
    }
  }

  await client.end();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
