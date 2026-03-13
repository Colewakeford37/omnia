import { Database } from '@nocobase/database';

export async function seedModuleTemplate(db: Database, count = 20) {
  const repo = db.getRepository('mod_records');
  for (let i = 1; i <= count; i += 1) {
    await repo.create({
      values: {
        title: `Record ${i}`,
        status: i % 3 === 0 ? 'inactive' : 'active'
      }
    });
  }
}
