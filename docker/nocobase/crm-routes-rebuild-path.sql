BEGIN;
TRUNCATE TABLE "main_desktopRoutes_path";

WITH RECURSIVE route_tree AS (
  SELECT d.id AS node_id,
         d."parentId" AS parent_id,
         d.id AS root_id,
         ('/' || d.id::text || '/')::varchar AS path_value
  FROM "desktopRoutes" d
  WHERE d."parentId" IS NULL

  UNION ALL

  SELECT c.id AS node_id,
         c."parentId" AS parent_id,
         rt.root_id,
         (rt.path_value || c.id::text || '/')::varchar AS path_value
  FROM "desktopRoutes" c
  JOIN route_tree rt ON c."parentId" = rt.node_id
)
INSERT INTO "main_desktopRoutes_path" ("nodePk", "path", "rootPk")
SELECT node_id, path_value, root_id
FROM route_tree;

COMMIT;
