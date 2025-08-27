package com.spring.teamProject.service;

import java.io.File;
import java.io.IOException;

/**
 * FTP 서버와의 파일 통신(업로드, 다운로드, 삭제)을 처리하는 서비스 인터페이스입니다.
 * 이 인터페이스는 실제 FTP 통신 로직을 추상화하여, 다른 서비스 계층에서 일관된 방식으로 FTP 기능을 사용할 수 있도록 합니다.
 */
public interface FtpService {

    /**
     * 지정된 로컬 파일을 FTP 서버의 특정 하위 디렉토리로 업로드합니다.
     * 이 메소드는 내부에 폴더 존재 여부를 확인하고, 없으면 생성하는 로직을 포함합니다.
     *
     * @param localFile        업로드할 로컬 파일 객체 (임시 저장소에 있는 파일)
     * @param subDirectory     FTP 서버의 기본 경로 하위에 있는 저장할 폴더 이름 (예: "profile", "banners")
     * @param remoteFileName   FTP 서버에 최종적으로 저장될 파일 이름 (예: "uuid.png")
     * @return 업로드 성공 시 true, 실패 시 false
     */
    boolean uploadFile(File localFile, String subDirectory, String remoteFileName);

    /**
     * FTP 서버의 특정 하위 디렉토리에서 파일을 다운로드하여 byte 배열로 반환합니다.
     * FileController에서 이 메소드를 사용하여 사용자에게 이미지를 보여줍니다.
     *
     * @param subDirectory     파일이 위치한 하위 폴더 이름
     * @param fileName         다운로드할 파일 이름
     * @return 파일의 바이너리 데이터 (byte 배열)
     * @throws IOException 파일이 없거나 FTP 서버 연결에 실패할 경우 발생
     */
    byte[] downloadFile(String subDirectory, String fileName) throws IOException;
    
    /**
     * FTP 서버의 특정 하위 디렉토리에서 파일을 삭제합니다.
     * DB에서 관련 정보가 성공적으로 삭제된 후에 호출하는 것을 권장합니다.
     *
     * @param subDirectory     파일이 위치한 하위 폴더 이름
     * @param fileName         삭제할 파일 이름
     * @return 삭제에 성공했거나, 파일이 원래부터 없었을 경우 true, 그 외 실패 시 false
     */
    boolean deleteFile(String subDirectory, String fileName);
}
