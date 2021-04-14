//
// Strapi helper
//
class Strapi {
  _baseURL = 'http://localhost:1337';

  // Remove or change fields by their names
  _mappingField = {
    id: '',
    published_at: '',
    created_at: 'date',
    updated_at: 'lastmod',
  };

  setBaseURL = (value: string) => (this._baseURL = value);

  async find(collection: string) {
    const url = `${this._baseURL}/${collection}/`;
    const res = await fetch(url);
    return await res.json();
  }

  async findOne(collection: string, id: string) {
    const url = `${this._baseURL}/${collection}/${id}`;
    const res = await fetch(url);
    return await res.json();
  }

  async create(collection: string, data: object) {
    const url = `${this._baseURL}/${collection}/`;
    return fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
  }

  async download(collection: string) {
    const items = await this.find(collection);
    for (const item of items) {
      // Mapping fields
      for (const [k, v] of Object.entries(this._mappingField)) {
        if (item[k]) {
          if (k) {
            item[v] = item[k];
          }

          delete item[k];
        }
      }

      // Write
    }
  }

  async upload(collection: string) {}
}

const instance = new Strapi();
export { instance as Strapi };
