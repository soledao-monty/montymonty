import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { MemoryCard, MemoryCardRow } from '../model/MemoryCard';

const STORE_NAME = 'MemoryFlow.db';
const TABLE_NAME = 'memory_cards';

class StorageService {
  private store: relationalStore.RdbStore | null = null;
  private context: common.Context | null = null;

  async init(context: common.Context): Promise<void> {
    this.context = context;
    const config: relationalStore.StoreConfig = {
      name: STORE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTable();
  }

  private async createTable(): Promise<void> {
    if (!this.store) return;

    const createTableSql = `
      CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        location TEXT,
        mediaUris TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    `;
    await this.store.executeSql(createTableSql);
  }

  async insert(memory: MemoryCard): Promise<number> {
    if (!this.store) {
      throw new Error('Storage not initialized');
    }

    const valueBucket: Record<string, string | number> = {
      id: memory.id,
      description: memory.description,
      timestamp: memory.timestamp,
      location: memory.location,
      mediaUris: JSON.stringify(memory.mediaUris),
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt
    };

    const result = await this.store.insert(TABLE_NAME, valueBucket);
    return result;
  }

  async queryAll(): Promise<MemoryCard[]> {
    if (!this.store) {
      throw new Error('Storage not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('timestamp');
    const resultSet = await this.store.query(predicates);

    const memories: MemoryCard[] = [];
    while (resultSet.goToNextRow()) {
      const row: MemoryCardRow = {
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        description: resultSet.getString(resultSet.getColumnIndex('description')),
        timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
        location: resultSet.getString(resultSet.getColumnIndex('location')),
        mediaUris: resultSet.getString(resultSet.getColumnIndex('mediaUris')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
      };
      memories.push(this.rowToMemory(row));
    }
    resultSet.close();

    return memories;
  }

  async queryById(id: string): Promise<MemoryCard | null> {
    if (!this.store) {
      throw new Error('Storage not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const resultSet = await this.store.query(predicates);

    if (!resultSet.goToFirstRow()) {
      resultSet.close();
      return null;
    }

    const row: MemoryCardRow = {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
      location: resultSet.getString(resultSet.getColumnIndex('location')),
      mediaUris: resultSet.getString(resultSet.getColumnIndex('mediaUris')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
    };
    resultSet.close();

    return this.rowToMemory(row);
  }

  async update(memory: MemoryCard): Promise<number> {
    if (!this.store) {
      throw new Error('Storage not initialized');
    }

    const valueBucket: Record<string, string | number> = {
      description: memory.description,
      timestamp: memory.timestamp,
      location: memory.location,
      mediaUris: JSON.stringify(memory.mediaUris),
      updatedAt: Date.now()
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', memory.id);
    const result = await this.store.update(valueBucket, predicates);
    return result;
  }

  async delete(id: string): Promise<number> {
    if (!this.store) {
      throw new Error('Storage not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const result = await this.store.delete(predicates);
    return result;
  }

  private rowToMemory(row: MemoryCardRow): MemoryCard {
    return {
      id: row.id,
      description: row.description,
      timestamp: row.timestamp,
      location: row.location,
      mediaUris: JSON.parse(row.mediaUris),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt
    };
  }
}

export const storageService = new StorageService();
