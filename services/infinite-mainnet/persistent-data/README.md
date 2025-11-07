# Persistent Data Directory

This directory is used to store persistent blockchain node data for the Infinite Drive node container.

## Contents

This directory will contain:

- **config/**: Node configuration files (genesis.json, config.toml, client.toml, keys, etc.)
- **data/**: Blockchain state data (databases, snapshots, validator state, etc.)

## Important Notes

- **This directory is mounted as a volume** in the Docker container to persist data across container restarts.
- **The contents of this directory are NOT tracked in Git** (except this README file).
- **Do not manually edit files** in this directory unless you understand the implications.
- **The node will automatically populate** this directory during initialization (`node-init` command).

## Initialization

When you first run the node initialization, the following will be created:

- Configuration files downloaded from the genesis URL
- Node keys (if generated)
- Database directories for blockchain state

## Backup Recommendations

If you need to backup your node data:

- Backup the entire `persistent-data/` directory
- Ensure the node is stopped before backing up to avoid corruption
- Restore by copying the directory back to this location

## Location Mapping

- **Host path**: `./persistent-data`
- **Container path**: `/home/ubuntu/.infinited`

This mapping is configured in `docker-compose.yml` under the `volumes` section.

