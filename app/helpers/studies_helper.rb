# -*- coding: utf-8 -*-
module StudiesHelper
  def licence_text(access = nil, html = true)
    text = Licence.text(access)
    unless html
      text.gsub!(/<\/?[^>]*>/, "")  # strips html tags
      text.gsub!(/&[^;]*;/, "")     # strips html entities
      text.gsub!(/^ +/, "")         # removes leading blanks
      text.gsub!(/\n\n\n*/, "\n\n") # removed multiple empty lines
    end
    text
  end
end

class Licence
  def self.text(access_type)
    haml do '
%p

  As the owner of the copyright in this material hereto, or duly
  authorised by the owner of the copyright in the material, I grant to
  The Australian National University, a non‑exclusive licence to publish
  the data and information contained in the material, for the purpose of
  further analysis and the publication of the results of such analysis,
  subject to the following conditions.

%dl
  %dt (1) UNDERTAKINGS BY USERS
  %dd
    %p

      Any person or institution applying for copies of the data in
      machine‑readable form, codebooks and/or other documents of assistance
      to the analysis of the data (with the exception of those described in
      Section (2) below), or for analysis of the data to be carried out by
      the Australian Social Science Data Archive shall be required by the
      Archive National Manager to give undertakings as set out in the
      Undertaking Form. The Australian Social Science Data Archive and The
      Australian National University accept no responsibility for the
      consequences of any breach of these undertakings.

    %p

      The Archive National Manager shall act at all times so as to fully
      preserve the individual confidentiality of survey respondents and
      their replies.

  %dt (2) PUBLICATION OF INFORMATION ABOUT MATERIAL
  %dd
    %p

      In order that information about the material deposited in the
      Australian Social Science Data Archive may be circulated among
      interested persons or institutions, the Archive National Manager may
      (subject to the constraint in Section (1) above) publish questionnaire
      forms, the text of particular questions and statistical summaries of
      answers to particular questions, codebooks and outline descriptions of
      the deposited material.

  %dt (3) AVAILABILITY OF DATA FOR ANALYSIS
  %dd= access_text(access_type)

  %dt (4) AVAILABILITY OF UNPUBLISHED REPORTS
  %dd
    %p

      Any unpublished reports or interpretations of analyses that are
      deposited in the Australian Social Science Data Archive shall be
      regarded as among the documents of assistance to the analysis of data
      referred to in Section (3) above.

  %dt (5) DESTRUCTION OF MATERIAL
  %dd
    %p

      While the Australian Social Science Data Archive takes every care to
      preserve the physical integrity of the data, The Australian National
      University shall incur no liability, either expressed or implicit, for
      the physical materials deposited with the Archive or for the loss of
      data or information in the operation of the Archive.

'
    end
  end

  private

  def self.access_text(access_type)
    case access_type
    when 'A' then unrestricted_access_text
    when 'B' then restricted_access_text
    when 'S' then deferred_access_text
    else          access_options_text
    end
  end

  def self.access_options_text
    haml do '
%p

  There are two standard types of access as detailed below. Other
  conditions can be negotiated with the Archive National Manager.
  Select the condition which is applicable:

%dl
  %dt
    (i) Unrestricted access. (Access A)
  %dd= unrestricted_access_text

  %dt
    (ii) Depositor required to give or withhold permission for access.
    (Access B)
  %dd= restricted_access_text
'
    end
  end

  def self.unrestricted_access_text
    haml do '
%p

  Copies of the data in machine‑readable form, codebooks and/or other
  documents of assistance to the analysis of data, and/or analyses of
  data, may be supplied by the Archive National Manager to any person or
  institution giving the undertakings referred to in Section (1) above.
  Upon request, the Archive National Manager shall send to the
  undersigned (or an authorised representative) information regarding
  the supply of such data.

'
    end
  end

  def self.restricted_access_text
    haml do '
%p

  No copies of the data in machine‑readable form, codebooks and/or other
  documents of assistance to the analysis of data (with the exception of
  those described in Section (2) above) shall be supplied, and no
  analysis of the data shall be carried out by the Australian Social
  Science Data Archive, except with the written permission of the
  undersigned or the undersigned\'s authorised representative in each
  case or class of cases; it being understood that consent shall be
  deemed to have been given unless the undersigned or an authorised
  representative has replied within 30 days to an email to the last
  email address that he or she registered with the Australian Social
  Science Data Archive.

'
    end
  end

  def self.deferred_access_text
    haml do '
%p

  No copies of the data in machine‑readable form, codebooks and/or other
  documents of assistance to the analysis of data (with the exception of
  those described in Section (2) above) shall be supplied, and no
  analysis of the data shall be carried out by the Australian Social
  Science Data Archive, except as specified by a separate agreement
  between the undersigned or the undersigned\'s authorised
  representative and the Australian Social Science Data Archive.

'
    end
  end

  def self.haml(&block)
    raise ArgumentError, "Missing block" unless block_given?
    Haml::Engine.new(block.call).render(block.binding)
  end
end
