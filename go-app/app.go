// +build wasm

// The UI is running only on a web browser. Therefore, the build instruction
// above is to compile the code below only when the program is built for the
// WebAssembly (wasm) architecture.

package main

import "github.com/maxence-charriere/go-app/v7/pkg/app"

// hello is a component that displays a simple "Hello World!". A component is a
// customizable, independent, and reusable UI element. It is created by
// embedding app.Compo into a struct.
type hello struct {
	app.Compo
}

// The Render method is where the component appearance is defined. Here, a
// "Hello World!" is displayed as a heading.
func (h *hello) Render() app.UI {
	return app.H1().Text("Hello World!")
}

// The main function is the entry point of the UI. It is where components are
// associated with URL paths and where the UI is started.
func main() {
	app.Route("/", &hello{}) // hello component is associated with URL path "/".
	app.Run()                // Launches the PWA.
}
