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

module cryptod.assymetric.rsa;

import cryptod.hash.sha1;

import std.bigint;//This should be replaced by a simpler, faster primitive.

private:
BigInt modPow(BigInt x, BigInt e, BigInt m)
{
	static one = BigInt(1);
	static two = BigInt(2);
	BigInt r = 1;

	while (e > 0)
	{
		if(e % two == one)
		{
			r = (r*x)%m;
		}
		e = e>>1;
		x = (x*x)%m;
	}
	return r;
}


public:

struct PublicKey
{
	BigInt e;
	BigInt n;
}

struct PrivateKey
{
	
}

BigInt RSAEP(PublicKey key, BigInt m) //c
{
	if (m >= key.n || m < 0)
		throw new Exception("message representative out of range");
	BigInt c = modPow(m, key.e, key.n);
	return c;	
}

BigInt RSAVP1(PublicKey key, BigInt s)
{
	if (s >= key.n || s < 0)
		throw new Exception("signature representative out of range");
		
	BigInt m = modPow(s, key.e, key.n);
	return m;	
}

//ubyte[] RSAES_OAEP_ENCRYPT(alias Hash = &SHA1ub)(PublicKey key, ubyte[] M, string L = "")//, alias MGF
//{
//	//BigInt m = OS2IP(M);
//	ulong mLen = M.length;
//	ulong hLen = Hash([]).length;
//	if(mLen > (k - 2*hLen - 2))
//		throw new Exception("message too long");
//		
//	lHash = Hash(L);
//	
//	ubyte[] PS = new ubyte[k - mLen - 2*hLen - 2];
//	writeln(PS);
//		
//	return [];
//}
//
//unittest
//{
//	RSAES_OAEP_ENCRYPT!()(PublicKey(), []);
//}

