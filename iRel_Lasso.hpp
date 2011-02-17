#ifndef IREL_LASSO_HPP
#define IREL_LASSO_HPP

#include "iRel.h"
#include <cstring>

extern "C" iBase_Error iRel_LAST_ERROR;

#define RETURN(CODE) ERROR((CODE), "");
#define RETURNR(CODE) ERRORR((CODE), "");

#define ERROR(CODE, MSG) do { *ierr = iRel_processError( (CODE), (MSG) ); \
                             return; } while(false)
#define ERRORR(CODE, MSG) return iRel_processError( (CODE), (MSG) )

#define CHK_ERROR(CODE) do { *ierr = (CODE);                              \
                             if ((CODE) != iBase_SUCCESS)                 \
                               return; } while(false)
#define CHK_ERRORR(CODE) do { if ((CODE) != iBase_SUCCESS)                \
                                return (CODE); } while(false)

static inline int
iRel_processError(int code, const char* desc)
{
  std::strncpy( iRel_LAST_ERROR.description, desc,
                sizeof(iRel_LAST_ERROR.description) );
  iRel_LAST_ERROR.description[sizeof(iRel_LAST_ERROR.description)-1] = '\0';
  return (iRel_LAST_ERROR.error_type = (iBase_ErrorType)code);
}

#endif