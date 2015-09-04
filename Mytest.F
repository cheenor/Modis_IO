#include "fintrf.h"
	subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C
C 注意：子程序名必须为mexFunction
C nlhs：用于记录输出参数（left hand side）的个数
C plhs：用于记录输出的指针数组，指向各个输出参数的首地址
C nrhs：用于记录输入参数（right hand side）的个数
C prhs：用于记录输入的指针数组，指向各个输入参数的首地址
	implicit none
	integer nlhs, nrhs
	mwPointer plhs(*), prhs(*)
!     Function declarations:
	mwPointer mxGetPr, mxGetM, mxGetN
	mwPointer mxCreateDoubleMatrix
C mxGetPr：获取数据的实数部分
C mxGetPi：获取数据的虚数部分，这里没有用到
C mxGetM：获取数据的行数
C mxGetN：获取数据的列数
C mxCreateDoubleMatrix：创建一个双精度Matlab矩阵
C
C     Array information:
      mwPointer x_pr, y_pr
      mwPointer m, n,a,b
      mwSize size

      real*8 x(100),y	
      integer mn,i
C-----------------------------------------------------------------------
C 获取输入数据的行数与列数，并判断数据个数是否超过100
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      size = m * n
C 获取从Matlab中输入的数据
      x_pr = mxGetPr(prhs(1))
      write(10,*)x_pr
C 将数据转化为双精度，并复制给Fortran中的 x，size表示数据个数
      call mxCopyPtrToReal8(x_pr,x,size)
 	  write(10,*)'***************'
 	  write(10,*)x
      mn=size
      do i=1,mn
      	y=y+x(i)*2
      enddo
C 将计算结果传给 Matlab
C 先创建一个双精度实矩阵，这里是1x1的
      plhs(1) = mxCreateDoubleMatrix(1,1,0) ! 如果第三个参数是1，则表示带虚部
      y_pr = mxGetPr(plhs(1))
C
C 将y的值（实数部分）复制给 y_pr，也就是传给 Matlab
      call mxCopyReal8ToPtr(y,y_pr,1) 
      return
      end
