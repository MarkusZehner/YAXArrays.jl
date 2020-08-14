@testset "Datasets" begin
  data = [rand(4,5,12), rand(4,5,12), rand(4,5)]
  axlist1 = [RangeAxis("XVals",1.0:4.0), CategoricalAxis("YVals",[1,2,3,4,5]), RangeAxis("Time",Date(2001,1,15):Month(1):Date(2001,12,15))]
  axlist2 = [RangeAxis("XVals",1.0:4.0), CategoricalAxis("YVals",[1,2,3,4,5])]
  props = [Dict("att$i"=>i) for i=1:3]
  c1,c2,c3 = (YAXArray(axlist1, data[1], props[1]),
  YAXArray(axlist1, data[2], props[2]),
  YAXArray(axlist2, data[3], props[3])
  )
  ds = Dataset(avar = c1, something = c2, smaller = c3)
  @testset "Basic functions" begin
    b = IOBuffer()
    show(b,ds)
    s = split(String(take!(b)),"\n")
    s2 = """
    YAXArray Dataset
    Dimensions:
    XVals               Axis with 4 Elements from 1.0 to 4.0
    YVals               Axis with 5 elements: 1 2 3 4 5
    Time                Axis with 12 Elements from 2001-01-15 to 2001-12-15
    Variables: avar something smaller """
    s2 = split(s2,"\n")
    @test s[[1,2,6]] == s2[[1,2,6]]
    @test all(i->in(i,s2), s[3:5])
    for n in [:avar, :something, :smaller, :XVals, :Time, :YVals]
      @test n in propertynames(ds)
      @test n in propertynames(ds, true)
    end
    @test :axes ∉ propertynames(ds)
    @test :cubes ∉ propertynames(ds)
    @test :axes ∈ propertynames(ds, true)
    #Test getproperty
    @test all(i->in(i,values(ds.axes)),axlist1)
    @test collect(keys(ds.cubes)) == [:avar, :something, :smaller]
    @test collect(values(ds.cubes)) == [c1,c2,c3]
    @test ds.avar === c1
    @test ds.something === c2
    @test ds.smaller === c3
    @test ds[:avar] === c1
    ds2 = ds[[:avar, :smaller]]
    @test collect(keys(ds2.cubes)) == [:avar, :smaller]
    @test collect(values(ds2.cubes)) == [c1,c3]
    @test YAXArrays.Datasets.fuzzyfind("hal", ["hallo","bla","something"]) == 1
    ds3 = ds[["av", "some"]]
    @test collect(keys(ds3.cubes)) == [:av, :some]
    @test collect(values(ds3.cubes)) == [c1,c2]
    @test ds["avar"] === c1
  end
end
