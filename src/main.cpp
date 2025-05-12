#include <AMF/components/Component.h>
#include <AMF/components/VideoEncoderVCE.h>
#include <AMF/core/Context.h>
#include <AMF/core/Factory.h>
#include <AMF/core/Platform.h>
#include <AMF/core/VulkanAMF.h>

#include <dlfcn.h>
#include <iostream>
#include <memory>

class AmfHandleWrapper {
public:
  static std::unique_ptr<AmfHandleWrapper> create() {
    amf_handle handle =
        dlopen(AMF_DLL_NAMEA, RTLD_NOW | RTLD_LOCAL | RTLD_DEEPBIND);
    if (!handle) {
      std::cerr << "Failed to load AMF library: " << dlerror() << std::endl;
      return nullptr;
    }

    return std::unique_ptr<AmfHandleWrapper>(new AmfHandleWrapper(handle));
  }
  ~AmfHandleWrapper() { dlclose(handle_); }

  amf_handle handle() const { return handle_; }

private:
  AmfHandleWrapper(amf_handle handle) : handle_(handle) {}

  amf_handle handle_;
};

#define RETURN_IF_FAILED(res, message)                                         \
  if (res != AMF_OK) {                                                         \
    std::cerr << "Error(" << res << ")" << " " << message << std::endl;        \
    return -1;                                                                 \
  }

int main() {
  std::unique_ptr<AmfHandleWrapper> dll_handle = AmfHandleWrapper::create();
  if (!dll_handle) {
    std::cerr << "Failed to load AMF library: " << dlerror() << std::endl;
    return -1;
  }

  AMFInit_Fn amf_init_fun = reinterpret_cast<AMFInit_Fn>(
      dlsym(dll_handle->handle(), AMF_INIT_FUNCTION_NAME));
  if (!amf_init_fun) {
    std::cerr << "Failed to find AMFInit function: " << dlerror() << std::endl;
    return -1;
  }
  amf::AMFFactory *factory{};
  AMF_RESULT res = amf_init_fun(AMF_FULL_VERSION, &factory);
  if (res != AMF_OK) {
    std::cerr << "Failed to initialize AMF: " << res << std::endl;
    return -1;
  }

  AMFQueryVersion_Fn amf_query_version_fun =
      reinterpret_cast<AMFQueryVersion_Fn>(
          dlsym(dll_handle->handle(), AMF_QUERY_VERSION_FUNCTION_NAME));
  if (!amf_query_version_fun) {
    std::cerr << "Failed to find AMFQueryVersion function: " << dlerror()
              << std::endl;
    return -1;
  }
  amf_uint64 version = 0;
  res = amf_query_version_fun(&version);
  if (res != AMF_OK) {
    std::cerr << "Failed to query AMF version: " << res << std::endl;
    return -1;
  }
  std::cout << "AMF version: " << AMF_GET_MAJOR_VERSION(version) << "."
            << AMF_GET_MINOR_VERSION(version) << "."
            << AMF_GET_SUBMINOR_VERSION(version) << "."
            << AMF_GET_BUILD_VERSION(version) << std::endl;

  amf::AMFContextPtr context0;
  res = factory->CreateContext(&context0);
  RETURN_IF_FAILED(res, "Failed to create AMF context");

  amf::AMFContext1Ptr context = amf::AMFContext1Ptr(context0);

  res = amf::AMFContext1Ptr(context)->InitVulkan(nullptr);
  RETURN_IF_FAILED(res, "Failed to initialize Vulkan");

  amf::AMFComponentPtr encoder;
  res = factory->CreateComponent(context, AMFVideoEncoderVCE_AVC, &encoder);
  RETURN_IF_FAILED(res, "Failed to create AMF encoder");

  res = encoder->SetProperty(AMF_VIDEO_ENCODER_USAGE,
                             AMF_VIDEO_ENCODER_USAGE_TRANSCONDING);
  RETURN_IF_FAILED(res, "Failed to set encoder usage");
  res = encoder->SetProperty(AMF_VIDEO_ENCODER_B_PIC_PATTERN, 0);
  RETURN_IF_FAILED(res, "Failed to set B picture pattern");
  res = encoder->SetProperty(AMF_VIDEO_ENCODER_QUALITY_PRESET,
                             AMF_VIDEO_ENCODER_QUALITY_PRESET_SPEED);
  RETURN_IF_FAILED(res, "Failed to set quality preset");

  res = encoder->SetProperty(AMF_VIDEO_ENCODER_TARGET_BITRATE, 20000000);
  RETURN_IF_FAILED(res, "Failed to set target bitrate ");
  res = encoder->SetProperty(AMF_VIDEO_ENCODER_FRAMERATE, AMFRate{30, 1});
  RETURN_IF_FAILED(res, "Failed to set frame rate");
  res = encoder->SetProperty(AMF_VIDEO_ENCODER_LOWLATENCY_MODE, true);
  RETURN_IF_FAILED(res, "Failed to set low latency mode");
  res = encoder->SetProperty(AMF_VIDEO_ENCODER_FRAMESIZE,
                             ::AMFConstructSize(1280, 720));
  RETURN_IF_FAILED(res, "Failed to set frame size");
  res = encoder->Init(amf::AMF_SURFACE_NV12, 1280, 720);
  RETURN_IF_FAILED(res, "Failed to initialize encoder");

  std::cout << "Successfully initialized AMF encoder" << std::endl;

  return 0;
}
