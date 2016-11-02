module DATOnlineStats
using OnlineStats
using Combinatorics
importall ..DAT
importall ..Cubes
importall ..Mask
import ...CABLABTools.totuple
export DATfitOnline


function DATfitOnline(xout,maskout,xin,maskin,cfun)
    for (mi,xi) in zip(maskin,xin)
        (mi & MISSING)==VALID && fit!(xout[1],xi)
    end
end


function DATfitOnline(xout,maskout,xin,maskin,splitmask,msplitmask,cfun)
  for (mi,xi,si) in zip(maskin,xin,splitmask)
      (mi & MISSING)==VALID && fit!(xout[cfun(si)],xi)
  end
end

function finalizeOnlineCube{T,N}(c::CubeMem{T,N})
    CubeMem{Float32,N}(c.axes,map(OnlineStats.value,c.data),c.mask)
end

function mapCube{T<:OnlineStat}(f::Type{T},cdata::AbstractCubeData;by=CubeAxis[],max_cache=1e7,cfun=identity,outAxis=nothing,kwargs...)
  inAxes=axes(cdata)
  #Now analyse additional by axes
  inaxtypes=map(typeof,inAxes)
  bycubes=filter(i->!in(i,inaxtypes),collect(by))
  if length(bycubes)==1
    outAxis==nothing && error("You have to specify an output axis")
    indata=(cdata,bycubes[1])
    isa(outAxis,DataType) && (outAxis=outAxis())
    outdims=(outAxis,)
    lout=length(outAxis)
    inAxes2=filter(i->!in(typeof(i),by) && in(i,axes(bycubes[1])),inAxes)
  elseif length(bycubes)>1
    error("more than one filter cube not yet supported")
  else
    indata=cdata
    lout=1
    outdims=()
    inAxes2=filter(i->!in(typeof(i),by),inAxes)
  end
  axcombs=combinations(inAxes2)
  totlengths=map(a->prod(map(length,a)),axcombs)*sizeof(Float32)*lout
  smallenough=totlengths.<max_cache
  axcombs=collect(axcombs)[smallenough]
  totlengths=totlengths[smallenough]
  if !isempty(totlengths)
    m,i=findmax(totlengths)
    ia=map(typeof,axcombs[i])
    outBroad=filter(ax->!in(typeof(ax),by) && !in(typeof(ax),ia),inAxes)
    indims=length(bycubes)==0 ? (totuple(ia),) : (totuple(ia),totuple(ia))
  else
    outBroad=filter(ax->!in(typeof(ax),by),inAxes)
    indims=length(bycubes)==0 ? () : ((),())
  end
  outBroad=map(typeof,outBroad)
  return mapCube(DATfitOnline,indata,cfun,outtype=f,indims=indims,outdims=outdims,outBroadCastAxes=outBroad,finalizeOut=finalizeOnlineCube,genOut=i->f())
end
end
