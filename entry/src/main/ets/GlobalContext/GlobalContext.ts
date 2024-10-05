// GlobalContext.ts
import relationalStore from '@ohos.data.relationalStore';

export class GlobalContext {
  private static instance: GlobalContext;
  private store: relationalStore.RdbStore = null;

  private constructor() {}

  public static getInstance(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  getStore(): relationalStore.RdbStore | null {
    return this.store;
  }

  setStore(store: relationalStore.RdbStore): void {
    this.store = store;
  }
}