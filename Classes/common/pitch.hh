#pragma once

#include <complex>
#include <vector>
#include <list>
#include <algorithm>
#include <cmath>
//{65,130,261,523,1046}, 
//{69,138,277,554,1108},
//{73,146,293,587,1174},
//{77,155,311,622,1244},
//{82,164,329,659,1318},
//{87,174,349,698,1396},
//{92,185,370,740,1479},
//{98,196,392,783,1567},
//{103,207,415,830,1661},
//{110,220,440,880,1760},
//{116,233,466,932,1864},
//{123,246,493,987,1975},

//{65,130,262,520},//SA
//{69,138,281,578},//ri
//{73,148,295,583},//RA
//{77,155,322,622},//ga
//{82,164,329,659},//GA
//{87,174,349,698},//ma
//{92,185,362,740},//MA
//{98,198,390,783},//PA
//{103,207,415,830},//da
//{110,220,440,880},//DA
//{116,233,466,932},//ni 4/ 2
//{123,247,491,987},//NI

//static float swaraRatio[] = {1,32.0/31,16.0/15,6.0/5,5.0/4,4.0/3,27.0/20,3.0/2,128.0/81,8.0/5,9.0/5,15.0/8};
//static float swaraRatio[] = {1,10.0/9,9.0/8,5.0/4,81.0/64,45.0/32,64.0/45,3.0/2,5.0/3,27.0/16,15.0/8,31.0/16};

/// struct to represent tones
struct Tone {
	static const std::size_t MAXHARM = 16; //48; ///< maximum harmonics
	static const std::size_t MINAGE = 12; ///< minimum age
	static const std::size_t MAXAGE = 70; ///< minimum age
	
	double freq; ///< frequency
	double db; ///< dezibels
	double stabledb; ///< stable decibels
	double harmonics[MAXHARM]; ///< harmonics array
	std::size_t age; ///< age
	Tone(); 
	void print() const; ///< prints Tone
	bool operator==(double f) const; ///< equality operator
	void update(Tone const& t); ///< update Tone
	/// compares left and right volume
	static bool dbCompare(Tone const& l, Tone const& r) { return l.db < r.db; }
};

static inline bool operator==(Tone const& lhs, Tone const& rhs) { return lhs == rhs.freq; }
static inline bool operator!=(Tone const& lhs, Tone const& rhs) { return !(lhs == rhs); }
static inline bool operator<=(Tone const& lhs, Tone const& rhs) { return lhs.freq < rhs.freq || lhs == rhs; }
static inline bool operator>=(Tone const& lhs, Tone const& rhs) { return lhs.freq > rhs.freq || lhs == rhs; }
static inline bool operator<(Tone const& lhs, Tone const& rhs) { return lhs.freq < rhs.freq && lhs != rhs; }
static inline bool operator>(Tone const& lhs, Tone const& rhs) { return lhs.freq > rhs.freq && lhs != rhs; }

static const unsigned FFT_P = 10;
static const std::size_t FFT_N = 1 << FFT_P;
static const std::size_t BUF_N = 2 * FFT_N; //2

/// analyzer class
 /** class to analyze input audio and transform it into useable data
 */
class Analyzer {
  public:
	/// fast fourier transform vector
	typedef std::vector<std::complex<float> > fft_t;
	/// list of tones
	typedef std::list<Tone> tones_t;
	/// constructor
	Analyzer(double rate, std::size_t step = 200);
	/** Add input data to buffer. This is thread-safe (against other functions). **/
//	template <typename InIt> void input(InIt begin, InIt end) {
//		while (begin != end) {
//			float s = *begin;
//			++begin;
//			m_peak *= 0.999;
//			float p = s * s;
//			if (p > m_peak) m_peak = p;
//			size_t w = m_bufWrite;
//			size_t w2 = (m_bufWrite + 1) % BUF_N;
//			size_t r = m_bufRead;
//			if (w2 == r) m_bufRead = (r + 1) % BUF_N;
//			m_buf[w] = s;
//			m_bufWrite = w2;
//		}
//	}
	 void input(float* sample, unsigned int length) {
		int c = 0;
		while (c < length) {
			float s = sample[c];
			c++;
			m_peak *= 0.999;
			float p = s * s;
			if (p > m_peak) m_peak = p;
			size_t w = m_bufWrite;
			size_t w2 = (m_bufWrite + 1) % BUF_N;
			size_t r = m_bufRead;
			if (w2 == r) { m_bufRead = (r + 1) % BUF_N;}
			m_buf[w] = s;
			m_bufWrite = w2;
		}
	}
	/** Call this to process all data input so far. **/
	void process();
	/** Get the raw FFT. **/
	fft_t const& getFFT() const { return m_fft; }
	/** Get the peak level in dB (negative value, 0.0 = clipping). **/
	double getPeak() const { return 10.0 * log10(m_peak); }
	/** Get a list of all tones detected. **/
	tones_t const& getTones() const { return m_tones; }
	/** Find a tone within the singing range; prefers strong tones around 200-400 Hz. **/
//	Tone const* findTone(float note,double minfreq = 70.0, double maxfreq = 700.0) const {

	/** 
	 * Returns  0 if found, -ve diff if the tone is lower than expected, +ve diff if the tone is higher 
	 */
	float findTone(double minfreq = 70.0, double maxfreq = 700.0) const {
		if (m_tones.empty()) { m_oldfreq = 0.0; return 0; }
		double db = std::max_element(m_tones.begin(), m_tones.end(), Tone::dbCompare)->db;
		Tone const* best = NULL;
		double bestscore = 0;
		for (tones_t::const_iterator it = m_tones.begin(); it !=  m_tones.end(); ++it) {
			if(it->db < db - 10.0 || it->freq < minfreq || it->age < Tone::MINAGE) continue;
			if(it->freq > maxfreq) break;

//			if(it->freq > (Tone::baseKattai * swaraRatio[note] + 4)) {
//				found =it->freq -  Tone::baseKattai * swaraRatio[note];
//			}
//			else if (it->freq < (Tone::baseKattai * swaraRatio[note] - 4)) { 
//				found = it->freq - Tone::baseKattai * swaraRatio[note];
//			} 
//			else
//				found =0;

//			printf("Note: %d  InputFreq: %f refFreq: %f ratio: %f Found: %d\n",note,it->freq,(Tone::baseKattai * swaraRatio[note]),swaraRatio[note],found);
			
//			for(i=min;i<=max ;i++) {
//				if ( it->freq < swaraFreqs[note][i] - 3) 
//				{found = (swaraFreqs[note][i] - it->freq); continue; }
//				else if (it->freq > swaraFreqs[note][i] + 3)
//				{ found = (it->freq - swaraFreqs[note][i]); continue; }
//				
//				found = 0;				
//				break;
//			}
//			if(found != 0) continue;
			double score = it->db - std::max(180.0, std::abs(it->freq - 300.0)) / 10.0;

			if (m_oldfreq != 0.0 && std::fabs(it->freq/m_oldfreq - 1.0) < 0.05) score += 10.0;
			if (best && bestscore > score) break;
			best = &*it;
			bestscore = score;
		}
//		if(best)
//			printf("Found!: Num elements checked: %d\n",found);
//		else 
//			printf("Not Found!: Num elements checked: %d\n",found);
		m_oldfreq = (best ? best->freq : 0.0);
		if(best) {
			printf("Freq: %f OldFreq: %f\n",best->freq,m_oldfreq);	
			return best->freq;
		}
		else
			return 0;
	}
	bool calcFFT();
	void calcTones();

  private:
	std::size_t m_step;
	double m_rate;
	std::vector<float> m_window;
	float m_buf[2 * BUF_N];
	volatile size_t m_bufRead, m_bufWrite;
	fft_t m_fft;
	std::vector<float> m_fftLastPhase;
	double m_peak;
	tones_t m_tones;
	mutable double m_oldfreq;
//	bool calcFFT(); shreesh
	void mergeWithOld(tones_t& tones) const;
};
