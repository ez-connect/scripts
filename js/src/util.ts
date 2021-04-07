import * as fs from 'fs';
import * as path from 'path';

class Util {
  walk(res: string[], dir: string, pattern?: RegExp): void {
    const names = fs.readdirSync(dir);
    for (const name of names) {
      const filename = path.join(dir, name);

      if (fs.statSync(filename).isDirectory()) {
        // Walk into each dir
        this.walk(res, filename, pattern);
      } else {
        // Or match
        const ok = pattern ? path.basename(filename).match(pattern) != null : true;
        if (ok) {
          res.push(filename);
        }
      }
    }
  }

  copyFilesSync(src: string, dest: string) {
    const names = fs.readdirSync(src);
    for (const name of names) {
      fs.copyFileSync(path.join(src, name), path.join(dest, name));
    }
  }

  copyDirSync(src: string, dest: string) {
    fs.readdirSync(src).forEach((e) => {
      if (fs.lstatSync(path.join(src, e)).isFile()) {
        fs.copyFileSync(path.join(src, e), path.join(dest, e));
      } else {
        fs.mkdirSync(path.join(dest, e));
        this.copyDirSync(path.join(src, e), path.join(dest, e));
      }
    });
  }

  write(filename: string, value: string) {
    fs.writeFileSync(filename, value);
  }

  writeJSON(filename: string, data: unknown) {
    this.write(filename, JSON.stringify(data, null, 2));
  }
}

const singleton = new Util();
export { singleton as Util };
