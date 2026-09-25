ExternalProject_Add(vulkan
    DEPENDS vulkan-header
    GIT_REPOSITORY https://github.com/KhronosGroup/Vulkan-Loader.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    UPDATE_COMMAND ""
    GIT_TAG v1.4.343
    # Always start from a clean v1.4.343 checkout: the update step can leave the
    # source on another commit (or half-patched), and then `git am` fails with
    # "sha1 information is lacking or useless / could not build fake ancestor".
    # Run via plain `sh -c` (not ${EXEC}), which would strip the quotes.
    PATCH_COMMAND sh -c "git am --abort 2>/dev/null; git fetch origin tag v1.4.343 --no-tags 2>/dev/null; git reset --hard v1.4.343 && git clean -fd"
          COMMAND ${EXEC} git am --3way ${CMAKE_CURRENT_SOURCE_DIR}/vulkan-*.patch
    CONFIGURE_COMMAND ${EXEC} CONF=1 cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
        -DCMAKE_FIND_ROOT_PATH=${MINGW_INSTALL_PREFIX}
        -DBUILD_SHARED_LIBS=OFF
        -DVULKAN_HEADERS_INSTALL_DIR=${MINGW_INSTALL_PREFIX}
        -DBUILD_TESTS=OFF
        -DENABLE_WERROR=OFF
        ${vulkan_asm}
        -DBUILD_STATIC_LOADER=ON
        -DCMAKE_C_FLAGS='${CMAKE_C_FLAGS} -D__STDC_FORMAT_MACROS -DSTRSAFE_NO_DEPRECATE -Dparse_number=cjson_parse_number'
        -DCMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS} -D__STDC_FORMAT_MACROS -fpermissive'
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/loader/libvulkan.a ${MINGW_INSTALL_PREFIX}/lib/libvulkan.a
            COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/loader/vulkan_own.pc ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/vulkan.pc
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(vulkan)
cleanup(vulkan install)
