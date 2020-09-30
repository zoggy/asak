FROM ocaml/opam2:4.11
# NB: opam-repositroy is here: /home/opam/opam-repository

RUN sudo apt-get update
RUN sudo apt-get install -y \
    pkg-config \
    # for ctypes
    libffi-dev \
    # for conf-*
    m4 ncurses-dev libgmp-dev zlib1g-dev gnuplot-x11 \
    libgtksourceview2.0-dev cpio libzstd-dev libzmq3-dev \
    wget vim time libtidy-dev libgdbm-dev zlib1g-dev \
    libsnappy-dev libsqlite3-dev tcl-dev libtidy-dev \
    libsfml-dev libsdl-ttf2.0-dev libsdl2-dev libsdl2-image-dev \
    libsdl2-mixer-dev libsdl2-net-dev libelementary-dev coinor-csdp \
    cmake clang llvm-6.0-dev autoconf librocksdb-dev libaio-dev

# Setup for asak
RUN mkdir /tmp/asak
ENV ASAK_PREFIX /tmp/asak

# Clone our custom repo
RUN rm -rf /home/opam/opam-repository
RUN git clone --branch asak_comp --single-branch --depth=1 https://github.com/nobrakal/opam-repository.git /home/opam/opam-repository

# Prepare a solver for marracheck
RUN git clone git clone https://github.com/sbjoshi/Open-WBO-Inc /home/opam/solver
RUN cd /home/opam/solver \
    && make r

ENV PATH="/home/opam/solver:${PATH}"

# Prepare marracheck
RUN git clone https://github.com/Armael/marracheck.git /home/opam/marracheck

RUN cd /home/opam/marracheck \
    && git submodule update --init --recursive \
    && opam switch create --deps-only . ocaml-base-compiler.4.09.1 \
    && eval $(opam env) \
    && dune build

RUN mkdir /home/opam/marracheck-work

VOLUME ["/tmp/asak"]

ENTRYPOINT dune exec -- src/marracheck.exe run ../opam-repository/ ../marracheck-work/ "ocaml-variants.4.11.2+asak"