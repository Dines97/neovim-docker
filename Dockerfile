FROM alpine:3.15.0 AS clone
WORKDIR /
RUN apk add git
RUN git clone https://github.com/neovim/neovim

WORKDIR /neovim
RUN git checkout tags/v0.6.1

FROM alpine:3.15.0 AS build
WORKDIR /src
RUN apk add build-base cmake automake autoconf libtool pkgconf coreutils curl unzip gettext-tiny-dev
COPY --from=clone /neovim .
RUN make -j8 CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/build install

FROM alpine:3.15.0 AS release
WORKDIR /neovim
RUN apk add libgcc curl git
COPY init.vim /root/.config/nvim/
RUN sh -c 'curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

COPY --from=build /build .
RUN ./bin/nvim --headless +PlugInstall +qall

WORKDIR /workspace
ENTRYPOINT /neovim/bin/nvim


