import json
import pathlib
import subprocess
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


class GenerationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        subprocess.run(["swift", "build", "--product", "LicenseProviderExec"], cwd=ROOT, check=True)
        bin_path = subprocess.check_output(["swift", "build", "--show-bin-path"], cwd=ROOT, text=True).strip()
        cls.executable = pathlib.Path(bin_path) / "LicenseProviderExec"

    def test_same_name_packages_generate_stable_content_without_rewriting(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            sources = [root / "xcode", root / "tuist"]
            for source, location in zip(sources, ["https://example.com/Library", "https://example.com/Library.git"]):
                checkout = source / "checkouts" / "Library"
                checkout.mkdir(parents=True)
                (checkout / "LICENSE").write_text("Example license\n")
                dependency = {
                    "packageRef": {"name": "Library", "kind": "remoteSourceControl", "location": location},
                    "subpath": "Library",
                }
                (source / "workspace-state.json").write_text(json.dumps({"object": {"dependencies": [dependency]}}))
            output = root / "LicenseProvider.swift"
            command = [str(self.executable), str(output), *map(str, sources)]
            subprocess.run(command, check=True)
            expected = output.read_bytes()
            original_mtime = output.stat().st_mtime_ns
            self.assertEqual(expected.count(b'name: "Library"'), 2)
            for _ in range(16):
                subprocess.run(command, check=True)
                self.assertEqual(output.read_bytes(), expected)
            self.assertEqual(output.stat().st_mtime_ns, original_mtime)
            subprocess.run([str(self.executable), str(output), *map(str, reversed(sources))], check=True)
            self.assertEqual(output.read_bytes(), expected)
            self.assertEqual(output.stat().st_mtime_ns, original_mtime)
            (sources[0] / "checkouts" / "Library" / "LICENSE").write_text("Updated license\n")
            subprocess.run(command, check=True)
            self.assertNotEqual(output.read_bytes(), expected)
            self.assertIn(b"Updated license", output.read_bytes())


if __name__ == "__main__":
    unittest.main()
