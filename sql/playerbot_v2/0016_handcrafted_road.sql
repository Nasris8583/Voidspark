-- Migration: 0016_handcrafted_road
-- Purpose: Runtime storage for operator-authored navigation road segments.
-- Reverts: yes (DROP TABLE handcrafted_road).

CREATE TABLE IF NOT EXISTS handcrafted_road (
    id        INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    mapId     INT UNSIGNED NOT NULL,
    fromX     FLOAT NOT NULL,
    fromY     FLOAT NOT NULL,
    toX       FLOAT NOT NULL,
    toY       FLOAT NOT NULL,
    width     FLOAT NOT NULL,
    comment   VARCHAR(255) NULL,
    verified  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    KEY idx_handcrafted_road_map (mapId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO playerbot_v2_schema_version (version, sha256) VALUES
    (16, REPEAT('0', 64))
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
