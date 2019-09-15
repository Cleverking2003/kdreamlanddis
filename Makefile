kirby.gb: kirby.asm
	rgbasm -o kirby.o kirby.asm
	rgblink -o kirby.gb kirby.o
	rgbfix -v -j -l 1 -m 1 -p 0 -t 'KIRBY DREAM LAND' kirby.gb
	diff kirby.gb baserom.gb

clean:
	rm -f *.o kirby.gb
