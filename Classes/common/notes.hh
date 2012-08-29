#pragma once
#include<iostream>

/// musical scale, defaults to C major
class MusicalScale {
  private:
	double m_baseFreq;
	static const int m_baseId = 33;

  public:
	/// constructor
	MusicalScale(double baseFreq = 440.0): m_baseFreq(baseFreq) {}
	/// get name of note
	std::string getNoteStr(double freq) const;
	/// get note number for id
	unsigned int getNoteNum(int id) const;
	/// true if sharp note
	bool isSharp(int id) const;
	/// get frequence for note id
	double getNoteFreq(int id) const;
	/// get note id for frequence
	int getNoteId(double freq) const;
	/// get note for frequence
	double getNote(double freq) const;
	/// get note offset for frequence
	double getNoteOffset(double freq) const;
};

