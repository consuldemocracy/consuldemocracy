 require "rails_helper"

RSpec.describe Legislation::Annotation, type: :model do
  let(:draft_version) { create(:legislation_draft_version) }
  let(:annotation) { create(:legislation_annotation, draft_version: draft_version) }

  it "is valid" do
    expect(draft_version).to be_valid
    expect(annotation).to be_valid
  end

  it "calculates the context for multinode annotations" do
    quote = "ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam"\
            " erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex"\
            " ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum"\
            " dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril"\
            " delenit augue duis dolore te feugait nulla facilisi."\
            "\n\n"\
            "Expetenda tincidunt in sed, ex partem placerat sea, porro commodo ex eam. His putant aeterno interesset at. Usu ea mundi"\
            " tincidunt, omnium virtute aliquando ius ex. Ea aperiri sententiae duo. Usu nullam dolorum quaestio ei, sit vidit facilisis"\
            " ea. Per ne impedit iracundia neglegentur. Consetetur neglegentur eum ut, vis animal legimus inimicus id."\
            "\n\n"\
            "His audiam"
    annotation = create(:legislation_annotation,
      draft_version: draft_version,
      quote: quote,
      ranges: [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[3]", "endOffset" => 11}]
    )

    context = "Lorem <span class=annotator-hl>ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt"\
              " ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper"\
              " suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit"\
              " esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui"\
              " blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.\n\nExpetenda tincidunt in sed, ex"\
              " partem placerat sea, porro commodo ex eam. His putant aeterno interesset at. Usu ea mundi tincidunt, omnium virtute"\
              " aliquando ius ex. Ea aperiri sententiae duo. Usu nullam dolorum quaestio ei, sit vidit facilisis ea. Per ne impedit"\
              " iracundia neglegentur. Consetetur neglegentur eum ut, vis animal legimus inimicus id.\n\nHis audiam</span>deserunt in, eum"\
              " ubique voluptatibus te. In reque dicta usu. Ne rebum dissentiet eam, vim omnis deseruisse id. Ullum deleniti vituperata at"\
              " quo, insolens complectitur te eos, ea pri dico munere propriae. Vel ferri facilis ut, qui paulo ridens praesent ad. Possim"\
              " alterum qui cu. Accusamus consulatu ius te, cu decore soleat appareat usu."
    expect(annotation.context).to eq(context)
  end

  it "calculates the context for multinode annotations 2" do
    quote = "Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla"\
            " facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore"\
            " te feugait nulla facilisi.\r\n\r\nExpetenda tincidunt in sed, ex partem placerat sea, porro commodo ex eam. His putant"\
            " aeterno interesset at. Usu ea mundi tincidunt, omnium virtute aliquando ius ex. Ea aperiri sententiae duo"
    annotation = create(:legislation_annotation,
      draft_version: draft_version,
      quote: quote,
      ranges: [{"start" => "/p[1]", "startOffset" => 273, "end" => "/p[2]", "endOffset" => 190}]
    )

    context = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna"\
              " aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut"\
              " aliquip ex ea commodo consequat. <span class=annotator-hl>Duis autem vel eum iriure dolor in hendrerit in vulputate velit"\
              " esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui"\
              " blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.\r\n\r\nExpetenda tincidunt in sed, ex"\
              " partem placerat sea, porro commodo ex eam. His putant aeterno interesset at. Usu ea mundi tincidunt, omnium virtute"\
              " aliquando ius ex. Ea aperiri sententiae duo</span>. Usu nullam dolorum quaestio ei, sit vidit facilisis ea. Per ne impedit"\
              " iracundia neglegentur. Consetetur neglegentur eum ut, vis animal legimus inimicus id."
    expect(annotation.context).to eq(context)
  end

  it "calculates the context for multinode annotations 3" do
    body = "The GNU Affero General Public License is a free, copyleft license for software and other kinds of works, specifically designed"\
           " to ensure cooperation with the community in the case of network server software.\r\n\r\nThe licenses for most software and"\
           " other practical works are designed to take away your freedom to share and change the works. By contrast, our General Public"\
           " Licenses are intended to guarantee your freedom to share and change all versions of a program--to make sure it remains free"\
           " software for all its users.\r\n\r\nWhen we speak of free software, we are referring to freedom, not price. Our General"\
           " Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for"\
           " them if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces"\
           " of it in new free programs, and that you know you can do these things.\r\n\r\nDevelopers that use our General Public Licenses"\
           " protect your rights with two steps: (1) assert copyright on the software, and (2) offer you this License which gives you"\
           " legal permission to copy, distribute and/or modify the software.\r\n\r\nA secondary benefit of defending all users' freedom"\
           " is that improvements made in alternate versions of the program, if they receive widespread use, become available for other"\
           " developers to incorporate. Many developers of free software are heartened and encouraged by the resulting cooperation."\
           " However, in the case of software used on network servers, this result may fail to come about. The GNU General Public License"\
           " permits making a modified version and letting the public access it on a server without ever releasing its source code to the"\
           " public.\r\n\r\nThe GNU Affero General Public License is designed specifically to ensure that, in such cases, the modified"\
           " source code becomes available to the community. It requires the operator of a network server to provide the source code of"\
           " the modified version running there to the users of that server. Therefore, public use of a modified version, on a publicly"\
           " accessible server, gives the public access to the source code of the modified version.\r\n\r\nAn older license, called the"\
           " Affero General Public License and published by Affero, was designed to accomplish similar goals. This is a different license,"\
           " not a version of the Affero GPL, but Affero has released a new version of the Affero GPL which permits relicensing under this"\
           " license."
    draft_version = create(:legislation_draft_version, body: body)

    quote = "By contrast, our General Public Licenses are intended to guarantee your freedom to share and change all versions of a"\
            " program--to make sure it remains free software for all its users.\r\n\r\nWhen we speak of free software, we are referring to"\
            " freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of"\
            " free software (and charge for them if you wish)"

    annotation = create(:legislation_annotation,
      draft_version: draft_version,
      quote: quote,
      ranges: [{"start" => "/p[2]", "startOffset" => 127, "end" => "/p[3]", "endOffset" => 223}]
    )

    context = "The licenses for most software and other practical works are designed to take away your freedom to share and change the"\
              " works. <span class=annotator-hl>By contrast, our General Public Licenses are intended to guarantee your freedom to share"\
              " and change all versions of a program--to make sure it remains free software for all its users.\r\n\r\nWhen we speak of"\
              " free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have"\
              " the freedom to distribute copies of free software (and charge for them if you wish)</span>, that you receive source code"\
              " or can get it if you want it, that you can change the software or use pieces of it in new free programs, and that you know"\
              " you can do these things."

    expect(annotation.context).to eq(context)
  end
end
