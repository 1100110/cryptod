<h1>cryptod.blockcipher.blockcipher</h1>
<br><br>
<dl><dt><big>abstract interface <u>BlockCipher</u>;
</big></dt>
<dd>All block ciphers have a set of common functionality
 let B be a block cipher, and let P be some plaintext
 where P.length == B.blockSize
<br><br>
Let C = B.Cipher(P) , then P == B.InvCipher(C)<br><br>

<dl><dt><big>abstract @property uint <u>blockSize</u>();
</big></dt>
<dd><br><br>
</dd>
<dt><big>abstract ubyte[] <u>Cipher</u>(ubyte[] <i>P</i>);
</big></dt>
<dd><br><br>
</dd>
<dt><big>abstract ubyte[] <u>InvCipher</u>(ubyte[] <i>C</i>);
</big></dt>
<dd><br><br>
</dd>
</dl>
</dd>
<dt><big>class <u>BadBlockSizeException</u>: object.Exception;
</big></dt>
<dd>This error is returned when you input a P of an infavourable blocksize.<br><br>

</dd>
</dl>