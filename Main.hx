import Float3.NativeArrayFloat3;
import hl.NativeArray;
import ShaderMath;

class Main {
	
	public static function main() {
		trace("main()");
		test_pointer();
		test_detourMath_0();
		test_rcCalcBounds_0();
		test_rcCalcBounds_1();
		test_detourRandomPointInConvexPoly();
		test_rcCreateHeightfield();
		test_rcMarkWalkableTriangles();
		test_rasterizeTriangle();
	}

	public static function approxEqual(a : Float, b : Float){
		if (Math.abs(a - b) < 0.001) {
			return true;
		} else {
			return false;
		}
	}

	public static function approxEqualVec3(a : Vec3, b : Vec3){
		return approxEqual(a.x, b.x) && approxEqual(a.y, b.y) && approxEqual(a.z, b.z);
	}

	public static function test_pointer(){
		var verts16 = new hl.NativeArray<hl.UI16>(3);
		var x = new recast.Native.DtNavMeshCreateParams();
		var bb = new hl.Bytes( 100 );	// need to make sure that there's enough bytes
		var bs : hl.BytesAccess<hl.UI16> = bb;
		bs[0] = 1;
		verts16[0] = 1;
		x.verts = bs;
		var xy = x.verts;

		var test = approxEqual(xy[0], 1);
		trace('test_pointer: $test');
	}

	public static function test_detourMath_0(){
		
		var test = true;

		var x : Float = -10.0;
		var y : Float = 10.0;

		var abs_x = recast.Native.DetourMath.dtMathFabsf(x);
		var abs_y = recast.Native.DetourMath.dtMathFabsf(y);

		test = test && approxEqual(10, abs_x);
		test = test && approxEqual(10, abs_y);

		trace('test_DetourMath_0: $test');
	}

	public static function test_rcCalcBounds_0(){
		var verts : Vec3.NativeArrayVec3 = new hl.NativeArray<Single>(3);
		var bmin = vec3(0., 0., 0.);
		var bmax = vec3(0., 0., 0.);
		verts[0] = vec3(1.,2.,3.);

		recast.Native.Recast.rcCalcBounds(verts, 1, bmin, bmax);
		
		var test = true;

		test = test && approxEqualVec3(bmin, verts[0]);
		test = test && approxEqualVec3(bmax, verts[0]);

		trace('test_rcCalcBounds (bounds of one vector): $test');
	}

	public static function test_rcCalcBounds_1(){
		var verts = new hl.NativeArray<Single>(6);
		var bmin = vec3(0., 0., 0.);
		var bmax = vec3(0., 0., 0.);
		verts[0] = 1;
		verts[1] =  2;
		verts[2] =  3;
		verts[3] =  0;
		verts[4] =  2;
		verts[5] =  5;
		recast.Native.Recast.rcCalcBounds(verts, 2, bmin, bmax);

		var test = true;

		test = test && approxEqual(bmin[0], 0.0);
		test = test && approxEqual(bmin[1], 2.0);
		test = test && approxEqual(bmin[2], 3.0);
		test = test && approxEqual(bmax[0], 1.0);
		test = test && approxEqual(bmax[1], 2.0);
		test = test && approxEqual(bmax[2], 5.0);

		trace('test_rcCalcBounds (bounds of more than one vect): $test');
	}

	public static function test_detourRandomPointInConvexPoly(){	
		var test = true;
		
		var pts = new NativeArray<Single>(9);
		pts[0] =0;
		pts[1] =0;
		pts[2] =0;
		pts[3] =0;
		pts[4] =0;
		pts[5] =1;
		pts[6] =1;
		pts[7] =0;
		pts[8] =0;

		var npts:Int = 3;

		var areas =  new NativeArray<Single>(6);
		var out =  new NativeArray<Single>(3);

		recast.Native.DetourCommon.dtRandomPointInConvexPoly(pts, npts, areas, 0.0, 1.0, out);
		test = test && approxEqual(out[0], 0.0);
		test = test && approxEqual(out[1], 0.0);
		test = test && approxEqual(out[2], 1.0);

		recast.Native.DetourCommon.dtRandomPointInConvexPoly(pts, npts, areas, 0.5, 1.0, out);
		test = test && approxEqual(out[0], 1.0 / 2.0);
		test = test && approxEqual(out[1], 0.0);
		test = test && approxEqual(out[2], 1.0 / 2.0);

		recast.Native.DetourCommon.dtRandomPointInConvexPoly(pts, npts, areas, 1.0, 1.0, out);
		test = test && approxEqual(out[0], 1.0);
		test = test && approxEqual(out[1], 0.0);
		test = test && approxEqual(out[2], 0.0);

		trace('test_detourRandomPointInConvexPoly: $test');
	}

	public static function test_rcCreateHeightfield(){	
		var test = true;
		
		var ctx = new recast.Native.RCContext(true);

		var verts = new NativeArray<Single>(6);
		verts[0] = 1;
		verts[1] = 2;
		verts[2] = 3;
		verts[3] = 0;
		verts[4] = 2;
		verts[5] = 6;

		var bmin = vec3(0., 0., 0.);
		var bmax = vec3(0., 0., 0.);

		recast.Native.Recast.rcCalcBounds(verts, 2, bmin, bmax);

		var cellSize:Float = 1.5;
		var cellHeight:Float = 2.0;

		var width = new NativeArray<Int>(1);
		var height = new NativeArray<Int>(1);

		recast.Native.Recast.rcCalcGridSize(bmin, bmax, cellSize, width, height);
		test = test && width[0] != 0;
		test = test && height[0] != 0;

		var heightfield = new recast.Native.Heightfield();

		test = test && ctx.rcCreateHeightfield(heightfield, width[0], height[0], bmin, bmax, cellSize, cellHeight);

		test = test && approxEqual(heightfield.width, width[0]);
		test = test && approxEqual(heightfield.height, height[0]);
		test = test && approxEqual(heightfield.bmin[0], bmin[0]);
		test = test && approxEqual(heightfield.bmin[1], bmin[1]);
		test = test && approxEqual(heightfield.bmin[2], bmin[2]);
		test = test && approxEqual(heightfield.cs, cellSize);
		test = test && approxEqual(heightfield.ch, cellHeight);
		test = test && heightfield.pools == null;
		test = test && heightfield.freelist == null;

		trace('test_rcCreateHeightfield: $test');
	}

	
	public static function test_rcMarkWalkableTriangles(){
		var RC_NULL_AREA = 0;
		var RC_WALKABLE_AREA:hl.UI8 = 63;
		
		var ctx = new recast.Native.RCContext(false);

		var verts = new NativeArray<Single>(9);
		verts[0] = 0;
		verts[1] = 0;
		verts[2] = 0;
		verts[3] = 1;
		verts[4] = 0;
		verts[5] = 0;
		verts[6] = 0;
		verts[7] = 0;
		verts[8] = -1;

		var walkableSlopeAngle:Float = 45;
		var nv:Int = 3;

		var walkable_tri = new NativeArray<Int>(3);
		walkable_tri[0] = 0;
		walkable_tri[1] = 1;
		walkable_tri[2] = 2;

		var unwalkable_tri = new NativeArray<Int>(3);
		unwalkable_tri[0] = 0;
		unwalkable_tri[1] = 2;
		unwalkable_tri[2] = 1;

		var nt:Int = 1;

		var areas = new NativeArray<hl.UI8>(1);
		
		// One walkable triangle
		areas[0] = RC_NULL_AREA;
		ctx.rcMarkWalkableTriangles(walkableSlopeAngle, verts, nv, walkable_tri, nt, areas);
		var test = areas[0] == RC_WALKABLE_AREA;
		trace('test_rcMarkWalkableTriangles. One walkable triangle : $test');

		// One non-walkable triangle
		areas[0] = RC_NULL_AREA;
		ctx.rcMarkWalkableTriangles(walkableSlopeAngle, verts, nv, unwalkable_tri, nt, areas);
		test = areas[0] == RC_NULL_AREA;
		trace('test_rcMarkWalkableTriangles. One non-walkable triangle : $test');

		// Non-walkable triangle area id's are not modified
		areas[0] = 42;
		ctx.rcMarkWalkableTriangles(walkableSlopeAngle, verts, nv, unwalkable_tri, nt, areas);
		test = areas[0] == 42;
		trace('test_rcMarkWalkableTriangles. Non-walkable triangle area ids are not modified : $test');

		// Slopes equal to the max slope are considered unwalkable.
		walkableSlopeAngle = 0;
		areas[0] = RC_NULL_AREA;
		ctx.rcMarkWalkableTriangles(walkableSlopeAngle, verts, nv, walkable_tri, nt, areas);
		test = areas[0] == RC_NULL_AREA;
		trace('test_rcMarkWalkableTriangles. Slopes equal to the max slope are considered unwalkable : $test');
	}

	public static function test_rasterizeTriangle(){
		var test = true;

		var ctx = new recast.Native.RCContext(true);

		var verts = new hl.NativeArray<Single>(9);
		verts[0] = 0;
		verts[1] = 0;
		verts[2] = 0;
		verts[3] = 1;
		verts[4] = 0;
		verts[5] = 0;
		verts[6] = 0;
		verts[7] = 0;
		verts[8] = -1;

		var bmin = vec3(0., 0., 0.);
		var bmax = vec3(0., 0., 0.);
		
		recast.Native.Recast.rcCalcBounds(verts, 3, bmin, bmax);
		var cellSize:Float = 0.5;
		var cellHeight:Float = 0.5;
		var width = new NativeArray<Int>(0);
		var height = new NativeArray<Int>(0);
	
		recast.Native.Recast.rcCalcGridSize(bmin, bmax, cellSize, width, height);
		test = test && width[0] != 0;
		test = test && height[0] != 0;

		var solid = new recast.Native.Heightfield();
		test = test && ctx.rcCreateHeightfield(solid, width[0], height[0], bmin, bmax, cellSize, cellHeight);
	
		var area = 42;
		var flagMergeThr = 1;
		test = test && ctx.rcRasterizeTriangle(
			vec3(verts[0], verts[1], verts[2]), 
			vec3(verts[3], verts[4], verts[5]), 
			vec3(verts[6], verts[7], verts[8]), 
			area, solid, flagMergeThr);

		test = test && solid.rcSpanIsValidAt(0 + 0 * width[0]);
		test = test && !solid.rcSpanIsValidAt(1 + 0 * width[0]);
		test = test && solid.rcSpanIsValidAt(0 + 1 * width[0]);
		test = test && solid.rcSpanIsValidAt(0 + 0 * width[0]);
		test = test && solid.rcSpanIsValidAt(1 + 1 * width[0]);

		test = test && solid.rcSpanAt(0 + 0 * width[0]).smin == 0;
		test = test && solid.rcSpanAt(0 + 0 * width[0]).smax == 1;
		test = test && solid.rcSpanAt(0 + 0 * width[0]).area == area;
		test = test && solid.rcSpanAt(0 + 0 * width[0]).next == null;
	
		test = test && solid.rcSpanAt(0 + 1 * width[0]).smin == 0;
		test = test && solid.rcSpanAt(0 + 1 * width[0]).smax == 1;
		test = test && solid.rcSpanAt(0 + 1 * width[0]).area == area;
		test = test && solid.rcSpanAt(0 + 1 * width[0]).next == null;

		test = test && solid.rcSpanAt(1 + 1 * width[0]).smin == 0;
		test = test && solid.rcSpanAt(1 + 1 * width[0]).smax == 1;
		test = test && solid.rcSpanAt(1 + 1 * width[0]).area == area;
		test = test && solid.rcSpanAt(1 + 1 * width[0]).next == null;

		trace ('test_rasterizeTriangle $test');
	}

}

