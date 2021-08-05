#include <iostream>
#include <memory>
#include <NvInfer.h>

class InferLogger: public nvinfer1::ILogger
{
public:
    void log(Severity severity, const char * msg) noexcept override
    {
        std::cerr << msg << '\n';
    }
};

/* this code is not particularly critical -- just using enough symbols
 * for the linker to be interested in supplied static libraries */

void foobar()
{
    InferLogger logger;
    std::unique_ptr<nvinfer1::IBuilder> builder_ptr{
        nvinfer1::createInferBuilder(logger)
    };
}
