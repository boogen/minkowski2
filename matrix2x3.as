package  
{

	public class matrix2x3
	{
		
		public var row0:vec2;
		public var row1:vec2;
		public var pos:vec2;
        public var angle:Number = 0;
		
		public function matrix2x3(angle:Number, pos:vec2) {
            this.angle = angle;
			row0 = new vec2(Math.cos(angle), -Math.sin(angle));
			row1 = new vec2(Math.sin(angle), Math.cos(angle));
			this.pos = pos;
		}

        public function setRotation(angle:Number):void {
            this.angle = angle;
            row0.x = Math.cos(angle);
            row0.y = -Math.sin(angle);
            row1.x = Math.sin(angle);
            row1.y = Math.cos(angle);
        }
		
		public function rotate(v:vec2):vec2 
		{
			return new vec2(row0.dot(v), row1.dot(v));
		}
		
		public function rotateIntoSpace(v:vec2):vec2
		{
			return row0.mul(v.x).add(row1.mul(v.y));
		}
		
		public function transform(v:vec2):vec2 
		{
			return rotate(v).add(pos);
		}
		
		public function reverse(v:vec2):vec2 
		{
			return rotateIntoSpace(v.sub(pos));
		}
		
	}

}