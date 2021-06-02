require 'pathname'
SOURCE_PATTERNS = ['*.ts', '*.tsx']
Pathname('.').glob(SOURCE_PATTERNS).each do |ts|
  next if /\.test\.ts$/ =~ ts.to_path
  next if /\.d\.ts$/ =~ ts.to_path

  mod = ts.basename(ts.extname)

  testpath = ts.dirname.join("#{mod}.test.ts")
  next if testpath.exist?

  puts("#{ts} => #{testpath} MISSING")
  testpath.write(%[import {#{mod}} from "./#{mod}";
describe("#{mod}", () => {
    test("importable", () => {
        expect(#{mod}).toBeDefined();
    });
});
])
end
