package main

import (
	"flag"
	"image"
	"image/png"
	"log"
	"os"

	"golang.org/x/image/draw"
	"suah.dev/protect"
)

func main() {
	var inFile = flag.String("in", "", "File to resize.")
	var outFile = flag.String("out", "", "Output file name.")
	var size = flag.Int("size", 64, "Size to resize to. This is one side of a square. 64 will produce a 64x64 square.")
	flag.Parse()

	protect.Unveil(*inFile, "r")
	protect.Unveil(*outFile, "rwc")
	protect.UnveilBlock()

	input, err := os.Open(*inFile)
	if err != nil {
		flag.Usage()
		os.Exit(1)
	}
	defer input.Close()

	output, err := os.Create(*outFile)
	if err != nil {
		flag.Usage()
		os.Exit(1)
	}
	defer output.Close()

	src, err := png.Decode(input)
	if err != nil {
		log.Fatal(err)
	}

	dst := image.NewRGBA(image.Rect(0, 0, *size, *size))
	draw.BiLinear.Scale(dst, dst.Rect, src, src.Bounds(), draw.Over, nil)
	png.Encode(output, dst)
}
