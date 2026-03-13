import { Plugin } from '@nocobase/server';
import { Database } from '@nocobase/database';

export class ModuleTemplatePlugin extends Plugin {
  async load() {
    const db = this.app.db as Database;
    db.collection({
      name: 'mod_records',
      title: 'Module Records',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'title', type: 'string', title: 'Title' },
        { name: 'status', type: 'string', title: 'Status' },
        { name: 'createdAt', type: 'datetime', title: 'Created At' },
        { name: 'updatedAt', type: 'datetime', title: 'Updated At' }
      ]
    });
  }
}
