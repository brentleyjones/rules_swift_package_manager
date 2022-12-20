package swift_test

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/bazelbuild/bazel-gazelle/rule"
	"github.com/cgrindel/swift_bazel/gazelle/internal/spreso"
	"github.com/cgrindel/swift_bazel/gazelle/internal/swift"
	"github.com/cgrindel/swift_bazel/gazelle/internal/swiftpkg"
	"github.com/stretchr/testify/assert"
)

func TestRepoRuleFromBazelRepo(t *testing.T) {
	pkgDir := "/path/to/package"
	miBasename := "module_index.json"

	t.Run("with pin (source control dep)", func(t *testing.T) {
		repoName := "swiftpkg_swift_argument_parser"
		remote := "https://github.com/apple/swift-argument-parser"
		version := "1.2.3"
		revision := "12345"
		p := &spreso.Pin{
			PkgRef: &spreso.PackageReference{
				Kind:     spreso.RemoteSourceControlPkgRefKind,
				Location: remote,
			},
			State: &spreso.VersionPinState{
				Version:  version,
				Revision: revision,
			},
		}
		br := &swift.BazelRepo{
			Name: repoName,
			Pin:  p,
		}
		actual, err := swift.RepoRuleFromBazelRepo(br, miBasename, pkgDir)
		assert.NoError(t, err)

		expected := rule.NewRule(swift.SwiftPkgRuleKind, repoName)
		expected.SetAttr("commit", revision)
		expected.SetAttr("remote", remote)
		expected.SetAttr("module_index", fmt.Sprintf("@//:%s", miBasename))
		expected.AddComment("# version: 1.2.3")
		assert.Equal(t, expected, actual)
	})
	t.Run("without pin (local Swift package)", func(t *testing.T) {
		pkgDir := "/path/to/package"
		relLocalPkgDir := "third_party/cool_local_package"
		localPkgDir := filepath.Join(pkgDir, relLocalPkgDir)
		repoName := "swiftpkg_cool_local_package"

		br := &swift.BazelRepo{
			Name: repoName,
			PkgInfo: &swiftpkg.PackageInfo{
				Name: "cool-local-package",
				Path: localPkgDir,
			},
		}
		actual, err := swift.RepoRuleFromBazelRepo(br, miBasename, pkgDir)
		assert.NoError(t, err)

		expected := rule.NewRule(swift.LocalSwiftPkgRuleKind, repoName)
		expected.SetAttr("path", relLocalPkgDir)
		expected.SetAttr("module_index", fmt.Sprintf("@//:%s", miBasename))
		assert.Equal(t, expected, actual)
	})
}
