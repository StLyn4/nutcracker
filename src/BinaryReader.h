
#pragma once

#include <iostream>
#include <algorithm>
#include <vector>
#include <locale>
#include <codecvt>
#include <stdint.h>
#include "Errors.h"

enum ArchType
{
	AT_UNKNOWN,
	AT_X32,
	AT_X64,
};

enum CharSize
{
	CS_UNKNOWN,
	CS_NORMAL,
	CS_WIDE,
};

// ************************************************************************************************************************************
class BinaryReader
{
private:
	std::istream& _in;

	// Delete default methods
	BinaryReader();
	BinaryReader( const BinaryReader& );
	BinaryReader& operator=( const BinaryReader& );

public:
	ArchType targetArch;
	CharSize charSize;

	explicit BinaryReader( std::istream& in )
	: _in(in)
	{
		targetArch = AT_UNKNOWN;
		charSize = CS_UNKNOWN;
	}

	// ******************************************************************************
	ArchType CheckArch( void )
	{
		std::streamoff currentPos = _in.tellg();

		_in.seekg(2, _in.beg);
		if (ReadInt32() == 'SQIR')
		{
			targetArch = AT_X32;
		}

		_in.seekg(2, _in.beg);
		if (ReadInt64() == 'SQIR')
		{
			targetArch = AT_X64;
		}

		_in.seekg(currentPos, _in.beg);
		return targetArch;
	}

	// ******************************************************************************
	CharSize CheckCharSize( void )
	{
		switch (ReadArchInt()) {
			case sizeof(char):
				charSize = CS_NORMAL;
				break;
			case sizeof(wchar_t):
				charSize = CS_WIDE;
				break;
			default:
				charSize = CS_UNKNOWN;
		}

		return charSize;
	}

	// ******************************************************************************
	void Read( void* buffer, uint64_t size )
	{
		if (size < 1)
			return;

		_in.read((char*)buffer, size);

		if (_in.fail())
			throw Error("I/O Error while reading from file.");
	}

	// ******************************************************************************
	template <typename T>
	T ReadValue( void )
	{
		T value;
		_in.read((char*)&value, sizeof(T));

		if (_in.fail())
			throw Error("I/O Error while reading from file.");

		return value;
	}

	// ******************************************************************************
	int8_t   ReadByte( void )    { return ReadValue<int8_t>();   }
	bool     ReadBool( void )    { return ReadValue<bool>();     }
	uint16_t ReadUInt16( void )  { return ReadValue<uint16_t>(); }
	int16_t  ReadInt16( void )   { return ReadValue<int16_t>();  }
	uint32_t ReadUInt32( void )  { return ReadValue<uint32_t>(); }
	int32_t  ReadInt32( void )   { return ReadValue<int32_t>();  }
	uint64_t ReadUInt64( void )  { return ReadValue<uint64_t>(); }
	int64_t  ReadInt64( void )   { return ReadValue<int64_t>();  }
	float    ReadFloat32( void ) { return ReadValue<float>();    }
	double   ReadFloat64( void ) { return ReadValue<double>();   }

	// ******************************************************************************
	uint64_t ReadArchUInt( void )
	{
		return targetArch == AT_X32 ? ReadUInt32() : ReadUInt64();
	}

	// ******************************************************************************
	int64_t ReadArchInt( void )
	{
		return targetArch == AT_X32 ? ReadInt32() : ReadInt64();
	}

	// ******************************************************************************
	void ConfirmOnPart( void )
	{
		int64_t data = ReadArchInt();

		if (data != 'PART')
			throw Error("Bad format of source binary file (PART marker was not match).");
	}


	// ******************************************************************************
	void ReadSQString( std::string& str )
	{
		static std::vector<char> buffer;
		uint64_t len = ReadArchUInt();
		size_t bytesLen = len * (charSize == CS_WIDE ? sizeof(wchar_t) : sizeof(char));
		size_t nullTerminatorSize = charSize == CS_WIDE ? sizeof(wchar_t) : sizeof(char);

		if (buffer.size() < bytesLen + nullTerminatorSize)
			buffer.resize(bytesLen + nullTerminatorSize);

		Read(buffer.data(), bytesLen);

		// Adding null terminator at the end of string
		buffer.insert(buffer.begin() + bytesLen, nullTerminatorSize, '\0');

		if (charSize == CS_WIDE)
		{
			// It may behave strangely if UTF-8 encoding is used
			using convert_type = std::codecvt_utf8<wchar_t>;
			std::wstring_convert<convert_type, wchar_t> converter;
			std::string convertedBuffer = converter.to_bytes((wchar_t*)buffer.data());
			str.assign(convertedBuffer);
		}
		else
		{
			str.assign(buffer.data(), bytesLen);
		}
	}


	// ******************************************************************************
	void ReadSQStringObject( std::string& str )
	{
		static const int StringObjectType = 0x10 | 0x08000000;
		static const int NullObjectType = 0x01 | 0x01000000;

		int32_t type = ReadInt32();

		if (type == StringObjectType)
			ReadSQString(str);
		else if (type == NullObjectType)
			str.clear();
		else
			throw Error("Expected string object not found in source binary file.");
	}

	std::streampos position() {
		return _in.tellg();
	}
};
