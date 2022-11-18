
build-bmp:
	mkdir ffmpegout -p
	ffmpeg -i BadApple.mp4 -vf fps=22 -s 120*90 ffmpegout/%02d.bmp

build-vdata:
	mkdir out -p
	luvit src/build_vdata.lua

build-vdata-nobase64:
	mkdir out -p
	luvit src/build_vdata_nobase64.lua

copysrc:
	mkdir out -p
	cp src/client/* -r out/

rojo-build:
	rojo build default.project.json -o badapple.rbxlx

rojo-serve:
	rojo serve testing.project.json

clean:
	rm -rf out 2>/dev/null
	rm -rf ffmpegout 2>/dev/null

build: clean build-bmp build-vdata copysrc rojo-build
