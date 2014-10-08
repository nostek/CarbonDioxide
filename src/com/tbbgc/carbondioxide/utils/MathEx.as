package com.tbbgc.carbondioxide.utils {
	/**
	 * @author Simon
	 */
	public class MathEx {
		static public function lerp( a:Number, b:Number, t:Number ):Number {
			return ( a + (b-a) * t );
		}
	}
}
