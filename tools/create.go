package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

type FeatureState string

const (
	APP     FeatureState = "app"
	GATEWAY FeatureState = "gateway"
	SERVICE FeatureState = "service"
	WEB     FeatureState = "web"
)

func main() {
	typeOfFeature := flag.String("feat", "", "type of feature (app, gateway, service, web)")
	nameOfFeature := flag.String("name", "", "name of feature (user, payment)")

	flag.Parse()

	if *typeOfFeature == "" || *nameOfFeature == "" {
		fmt.Println("Usage: go run tools/create.go -feat=app -name=user")
		os.Exit(1)
	}

	err := createFeature(FeatureState(*typeOfFeature), *nameOfFeature)
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}

	fmt.Printf("Feature '%s' (%s) created successfully.\n", *nameOfFeature, *typeOfFeature)
}

// =======================================================
//   SINGLE GENERATOR FUNCTION (NO REPEATED CODE)
// =======================================================

func createFeature(ft FeatureState, name string) error {

	layout := map[FeatureState][]string{
		APP: {
			"cmd",
			"internal/domain",
			"internal/service",
			"internal/infrastructure/events",
			"internal/infrastructure/grpc",
			"internal/infrastructure/repository",
			"pkg/types",
		},
		GATEWAY: {
			"cmd",
			"internal/domain",
			"internal/service",
			"internal/infrastructure/http",
			"internal/infrastructure/events",
			"internal/infrastructure/grpc",
			"pkg/types",
		},
		SERVICE: {
			"cmd",
			"internal/domain",
			"internal/service",
			"internal/infrastructure/repository",
			"internal/infrastructure/events",
			"internal/infrastructure/grpc",
			"pkg/types",
		},
		WEB: {
			"cmd",
			"internal/handlers",
			"internal/services",
			"internal/templates",
			"public/css",
			"public/js",
		},
	}

	baseRoot := map[FeatureState]string{
		APP:     "apps",
		GATEWAY: "gateways",
		SERVICE: "services",
		WEB:     "web",
	}

	root, ok := baseRoot[ft]
	if !ok {
		return fmt.Errorf("unknown feature type: %s", ft)
	}

	// ❤️ New correct naming rule: type-name
	basePath := filepath.Join(root, fmt.Sprintf("%s-%s", ft, name))

	// Create folders
	for _, dir := range layout[ft] {
		full := filepath.Join(basePath, dir)
		if err := os.MkdirAll(full, 0755); err != nil {
			return err
		}
	}

	// Create README
	readme := fmt.Sprintf(`# %s %s

Auto-generated %s named "%s".

Path:
%s
`, ft, name, ft, name, basePath)

	if err := os.WriteFile(filepath.Join(basePath, "README.md"), []byte(readme), 0644); err != nil {
		return err
	}

	return nil
}

// Tiny helper: renders a basic tree preview.
func renderTree(root string) string {
	return fmt.Sprintf("%s/\n  ... generated folders ...", root)
}
