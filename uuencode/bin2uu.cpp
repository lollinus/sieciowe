#include <iostream>
#include <vector>
#include <assert.h>
#include <fstream>
#include <iterator>

using std::cin;
using std::cout;
using std::endl;

class Paczka {
public:
    Paczka( char a, char b, char c );
    ~Paczka() {}
    
    operator const std::string &( ) const { return out; }
private:
    std::string out;
};

Paczka::Paczka( char a, char b, char c )
{
    unsigned long x = c + ( b << 8 ) + (a << 16 );

    char tmp[5];

    for( int i = 0; i < 4; i++ )
    {
        tmp[3-i] = ( x >> i*6 ) & 0x3f;
        tmp[3-i] += ' ';
        if ( tmp[3-i] == ' ' ) tmp[3-i] = '`';
    }
    tmp[4] = 0;

    out = tmp;
}

class UuLine {
public:
    UuLine( const std::vector<Paczka> &v, int size ) : vect(v), ls(size) {}
    ~UuLine() {}

    std::string GetLine() const
        {
            char len = ' ' + ls;
            std::string line; line.push_back( len );
            for( std::vector<Paczka>::const_iterator i = vect.begin(); i != vect.end(); i++ )
                line += *i;
            return line;
        }
private:
	int ls;
    std::vector<Paczka> vect;
};

int main()
{
    std::istreambuf_iterator<char> i( cin );
    std::istreambuf_iterator<char> eos;

	cout << "begin 644 testuu" << endl;

    while( eos != i) {
        int cc = 0;
        std::vector<Paczka> data;

        while( (cc <= 42) && (eos != i) ) {
            char a = ( eos != i )? (cc++, *i++) : 0;
            char b = ( eos != i )? (cc++, *i++) : 0;
            char c = ( eos != i )? (cc++, *i++) : 0;
            data.push_back( Paczka( a, b, c ) );
        }
        
        UuLine l( data, cc );

        cout << l.GetLine() << endl;
    }

	cout << "`" << endl << "end" << endl;
}
