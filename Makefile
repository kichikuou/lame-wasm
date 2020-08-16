LAME_DIR=$(CURDIR)/lame

DIST_DIR=$(LAME_DIR)/dist
LAME_SO=$(DIST_DIR)/lib/libmp3lame.so

all: lame.wasm

$(LAME_SO):
	cd $(LAME_DIR) && \
	emconfigure ./configure \
		CFLAGS="-DNDEBUG -Oz" \
		--prefix="$(DIST_DIR)" \
		--host=x86-none-linux \
		--disable-static \
		\
		--disable-gtktest \
		--disable-analyzer-hooks \
		--disable-decoder \
		--disable-frontend \
		&& \
	emmake make -j8 && \
	emmake make install

lame.wasm: $(LAME_SO)
	emcc $^ \
		-Oz \
		-s ENVIRONMENT=worker \
		-s MODULARIZE=1 \
		-s "EXPORTED_FUNCTIONS=['_malloc', '_free', '_lame_init', '_lame_set_mode', '_lame_set_num_channels', '_lame_set_in_samplerate', '_lame_set_VBR', '_lame_set_VBR_q', '_lame_init_params', '_lame_encode_buffer_interleaved', '_lame_encode_flush', '_lame_close']" \
		-o lame.js

clean:
	rm -rf lame.js lame.wasm $(DIST_DIR)
	cd $(LAME_DIR) && make clean
