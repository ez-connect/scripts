import fs from 'fs';
import path from 'path';
import { Util } from './util';

class Localization {
  properties: { [key: string]: { [key: string]: string } } = {};

  readProperties(dir: string, pattern?: RegExp): void {
    const names: string[] = [];
    Util.walk(names, dir, pattern);

    for (const name of names) {
      // console.log('Read file:', name);
      const lines = fs
        .readFileSync(name, { encoding: 'utf-8' })
        .toString()
        .split('\n');

      const data: { [key: string]: string } = {};
      for (const line of lines) {
        const m = line.match(/\s*([\w\..]+)=(.*)\s*/);
        if (m == null || m.length != 3) {
          // console.warn("Not match:", line);
          continue;
        }

        data[m[1]] = m[2];
        const page = path.basename(name).split('_')[0];
        this.properties[page] = data;
      }
    }
  }
}

const instance = new Localization();
export { instance as Localization };
