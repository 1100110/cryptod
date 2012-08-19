// Written in the D programming language

/*	Copyright Andrey A Popov 2012
 * 
 *	Permission is hereby granted, free of charge, to any person or organization
 *	obtaining a copy of the software and accompanying documentation covered by
 *	this license (the "Software") to use, reproduce, display, distribute,
 *	execute, and transmit the Software, and to prepare derivative works of the
 *	Software, and to permit third-parties to whom the Software is furnished to
 *	do so, all subject to the following:
 *	
 *	The copyright notices in the Software and this entire statement, including
 *	the above license grant, this restriction and the following disclaimer,
 *	must be included in all copies of the Software, in whole or in part, and
 *	all derivative works of the Software, unless such copies or derivative
 *	works are solely in the form of machine-executable object code generated by
 *	a source language processor.
 *	
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 *	SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 *	FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 *	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *	DEALINGS IN THE SOFTWARE.
 */

/**
 * Authors: Andrey A. Popov, andrey.anat.popov@gmail.com
 */

module cryptod.hash.md5;

import std.string, std.format, std.array;

import cryptod.hash.hash;

/**
 * MD5 function that uses the MD5 context and takes a simple string argument.
 */
ubyte[] MD5s(string s)
{
	return MD5ub(cast(ubyte[]) s);
}
/**
 * MD5 function that uses the MD5 context and takes a simple ubyte[] argument.
 */
ubyte[] MD5ub(ubyte[] s)
{
	auto md0 = new MD5Context();
	md0.AddToContext(s);
	md0.End();
	ubyte[] ret = md0.AsBytes();
	return ret;
}

class MD5Context
{
	private:
	
	union words { ubyte[16*4] b; uint[16] i; }
	
	static immutable uint T[] = [0,//The zero is there because the spec starts counting from 1 :/
	0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,  
	0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,  
	0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,  
	0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,  
	0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,  
	0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,  
	0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,  
	0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,  
	0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,  
	0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,  
	0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,  
	0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,  
	0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,  
	0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,  
	0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,  
	0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391];
	
	void PadMessage()
	{
		M ~= 0b10000000;
//		while(M.length % 64 != 56)
//		{
//			M ~= 0;
//		}
		M ~= new ubyte[(M.length>56)?(64-M.length+56):(56-(M.length % 64))];//more D-like
		PadLength();
	}
	//Pads the message with the message length as too spec. Lowest order bits first.
	void PadLength()
	{
		messageLength *= 8; //converts byte length to bits. I'm not sure that supporting bit adding to digests is a good idea performance-wise.
		M ~= [messageLength & 0xff, (messageLength >> 8) & 0xff, (messageLength >> 16) & 0xff,
		(messageLength >> 24) & 0xff, (messageLength >> 32) & 0xff, (messageLength >> 40) & 0xff,
		(messageLength >> 48) & 0xff, (messageLength >> 56) & 0xff];
	}
	
	uint ROTL(uint x, uint n) 
	{ return ( x << n ) | ( x >> ( 32-n ) ); }
	
	uint F(uint x, uint y, uint z) @safe pure nothrow
	{
		return ( ( x & y ) | ( ( ~x ) & z ) );
	}

	uint G(uint x, uint y, uint z) @safe pure nothrow
	{
		return ( ( x & z ) | ( y & ~z ) );
	}
	
	uint H(uint x, uint y, uint z) @safe pure nothrow
	{
		return ( x ^ y ^ z );
	}
	
	uint I(uint X, uint Y, uint Z) @safe pure nothrow
	{
		return Y ^ (X | ~Z);
	}
	
	void round1(ref uint a, uint b, uint c, uint d, uint x, uint s, uint i)
	{
		a = b + ROTL((a + F(b,c,d) + X[x] + T[i]), s);
	}
	
	void round2(ref uint a, uint b, uint c, uint d, uint x, uint s, uint i)
	{
		a = b + ROTL((a + G(b,c,d) + X[x] + T[i]), s);
	}
	
	void round3(ref uint a, uint b, uint c, uint d, uint x, uint s, uint i)
	{
		a = b + ROTL((a + H(b,c,d) + X[x] + T[i]), s);
	}
	
	void round4(ref uint a, uint b, uint c, uint d, uint x, uint s, uint i)
	{
		a = b + ROTL((a + I(b,c,d) + X[x] + T[i]), s);
	}
	
	ubyte[] M;
	uint[16] X;
	ulong messageLength;
	uint A, AA;
	uint B, BB;
	uint C, CC;
	uint D, DD;
	
	void AddToHash(ubyte[] H)
	{
		words Xw;
		for(uint i = 0; i < H.length/64; i++)
		{
//			for(uint j = 0; j < 16; j++)
//			{
//				ubyte[4] w = H[i*64+4*j..i*64+4*j+4];
//				X[j] = w[0] + (w[1]<<8)+(w[2]<<16)+(w[3]<<24);
//			}
			Xw.b = H[i*64..i*64+4*16]; //This is much faster :)
			X[] = Xw.i;
			
			//Saves A, B, C, and D.
			AA = A;
			BB = B;
			CC = C;
			DD = D;
			
			//round1
			round1(A, B, C, D,  0,  7,  1);  round1(D, A, B, C,  1, 12,  2);  round1(C, D, A, B,  2, 17,  3);  round1(B, C, D, A,  3, 22,  4);
			round1(A, B, C, D,  4,  7,  5);  round1(D, A, B, C,  5, 12,  6);  round1(C, D, A, B,  6, 17,  7);  round1(B, C, D, A,  7, 22,  8);
			round1(A, B, C, D,  8,  7,  9);  round1(D, A, B, C,  9, 12, 10);  round1(C, D, A, B, 10, 17, 11);  round1(B, C, D, A, 11, 22, 12);
			round1(A, B, C, D, 12,  7, 13);  round1(D, A, B, C, 13, 12, 14);  round1(C, D, A, B, 14, 17, 15);  round1(B, C, D, A, 15, 22, 16);
			
			//round2
			round2(A, B, C, D,  1,  5, 17);  round2(D, A, B, C,  6,  9, 18);  round2(C, D, A, B, 11, 14, 19);  round2(B, C, D, A,  0, 20, 20);
			round2(A, B, C, D,  5,  5, 21);  round2(D, A, B, C, 10,  9, 22);  round2(C, D, A, B, 15, 14, 23);  round2(B, C, D, A,  4, 20, 24);
			round2(A, B, C, D,  9,  5, 25);  round2(D, A, B, C, 14,  9, 26);  round2(C, D, A, B,  3, 14, 27);  round2(B, C, D, A,  8, 20, 28);
			round2(A, B, C, D, 13,  5, 29);  round2(D, A, B, C,  2,  9, 30);  round2(C, D, A, B,  7, 14, 31);  round2(B, C, D, A, 12, 20, 32);
			
			//round3
			round3(A, B, C, D,  5,  4, 33);  round3(D, A, B, C,  8, 11, 34);  round3(C, D, A, B, 11, 16, 35);  round3(B, C, D, A, 14, 23, 36);
			round3(A, B, C, D,  1,  4, 37);  round3(D, A, B, C,  4, 11, 38);  round3(C, D, A, B,  7, 16, 39);  round3(B, C, D, A, 10, 23, 40);
			round3(A, B, C, D, 13,  4, 41);  round3(D, A, B, C,  0, 11, 42);  round3(C, D, A, B,  3, 16, 43);  round3(B, C, D, A,  6, 23, 44);
			round3(A, B, C, D,  9,  4, 45);  round3(D, A, B, C, 12, 11, 46);  round3(C, D, A, B, 15, 16, 47);  round3(B, C, D, A,  2, 23, 48);
			
			//round4
			round4(A, B, C, D,  0,  6, 49);  round4(D, A, B, C,  7, 10, 50);  round4(C, D, A, B, 14, 15, 51);  round4(B, C, D, A,  5, 21, 52);
			round4(A, B, C, D, 12,  6, 53);  round4(D, A, B, C,  3, 10, 54);  round4(C, D, A, B, 10, 15, 55);  round4(B, C, D, A,  1, 21, 56);
			round4(A, B, C, D,  8,  6, 57);  round4(D, A, B, C, 15, 10, 58);  round4(C, D, A, B,  6, 15, 59);  round4(B, C, D, A, 13, 21, 60);
			round4(A, B, C, D,  4,  6, 61);  round4(D, A, B, C, 11, 10, 62);  round4(C, D, A, B,  2, 15, 63);  round4(B, C, D, A,  9, 21, 64);
			
			A += AA;
			B += BB;
			C += CC;
			D += DD;
		}
	}
	
	public:
	this()
	{
		M = [];
		messageLength = 0;
		A = 0x67452301;//Magic constants voodoo
		B = 0xefcdab89;//This one calls Cthulu
		C = 0x98badcfe;//This one is the One Ring
		D = 0x10325476;//This one is literally Hitler
	}
	
	ubyte[] AsBytes()
	{
		return [(A)&0xff, (A>>8)&0xff, (A>>16)&0xff, (A>>24)&0xff,
		(B)&0xff, (B>>8)&0xff, (B>>16)&0xff, (B>>24)&0xff,
		(C)&0xff, (C>>8)&0xff, (C>>16)&0xff, (C>>24)&0xff,
		(D)&0xff, (D>>8)&0xff, (D>>16)&0xff, (D>>24)&0xff];//Returns values with the least sig. byte first.
	}
	
	string AsString()
	{
		auto writer = appender!string();
		formattedWrite(writer, "%(%02x%)",AsBytes());
		return writer.data;
	}
	
	void AddToContext(string s)
	{
		AddToContext(cast(ubyte[])s);
	}
	
	void AddToContext(ubyte[] m)
	{
		messageLength += m.length;
		ubyte[] Z = M ~ m;
		ubyte[] H = Z[0..(Z.length-(Z.length%64))];
		M = Z[Z.length-(Z.length%64)..Z.length];
		//ulong zl = M.length+m.length;
		//ubyte[]H = (M~m)[0..(zl-(zl%64))];
		//M = 
		
		if(H.length > 0)
			AddToHash(H);
	}
	
	void End()
	{
		PadMessage();
		AddToHash(M);
	}
}

unittest
{
	import std.stdio, std.format;
	string ths(ubyte[] h)
	{
		auto writer = appender!string();
		formattedWrite(writer, "%(%02x%)",h);
		return writer.data;
	}
	
	assert(ths(MD5s("")) == "d41d8cd98f00b204e9800998ecf8427e");
	assert(ths(MD5s("a")) == "0cc175b9c0f1b6a831c399e269772661");
	assert(ths(MD5s("abc")) == "900150983cd24fb0d6963f7d28e17f72");
	assert(ths(MD5s("message digest")) == "f96b697d7cb7938d525a2f31aaf161d0");
	assert(ths(MD5s("abcdefghijklmnopqrstuvwxyz")) == "c3fcd3d76192e4007dfb496cca67e13b");
	assert(ths(MD5s("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")) == "d174ab98d277d9f5a5611c2c9f419d9f");
	assert(ths(MD5s("12345678901234567890123456789012345678901234567890123456789012345678901234567890")) == "57edf4a22be3c955ac49da2e2107b67a");
	
	writeln("MD5 unittest passed.");
}