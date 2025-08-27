package com.spring.teamProject.service;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * FtpService 인터페이스를 구현한 클래스.
 * FTP 서버와의 파일 통신(업로드, 다운로드, 삭제)에 대한 실제 로직을 처리합니다.
 */
@Service
public class FtpServiceImpl implements FtpService {

    private static final Logger logger = LoggerFactory.getLogger(FtpServiceImpl.class);

    @Value("${ftp.server.host}")
    private String host;
    @Value("${ftp.server.port}")
    private int port;
    @Value("${ftp.server.username}")
    private String username;
    @Value("${ftp.server.password}")
    private String password;
    @Value("${ftp.server.directory}")
    private String baseDirectory;

    @Override
    public boolean uploadFile(File localFile, String subDirectory, String remoteFileName) {
        FTPClient ftpClient = new FTPClient();
        try (FileInputStream fis = new FileInputStream(localFile)) {
            // 1. FTP 서버 연결 및 로그인
            ftpClient.connect(host, port);
            if (!ftpClient.login(username, password)) {
                logger.error("FTP 로그인 실패! application.properties의 계정 정보를 확인하세요.");
                return false;
            }
            logger.info("FTP 서버 연결 성공: {}", host);

            // 2. 데이터 전송을 위한 설정 (패시브 모드, 바이너리 타입)
            ftpClient.enterLocalPassiveMode();
            ftpClient.setFileType(FTP.BINARY_FILE_TYPE);

            // 3. application.properties에 설정된 기본 디렉토리로 이동합니다.
            if (StringUtils.hasText(baseDirectory) && !ftpClient.changeWorkingDirectory(baseDirectory)) {
                logger.error("FTP 기본 디렉토리({})로 이동을 실패했습니다. 경로를 확인하세요.", baseDirectory);
                return false;
            }

            // 4. 지정된 하위 폴더가 있으면 해당 폴더로 이동합니다. 없으면 새로 생성합니다.
            if (StringUtils.hasText(subDirectory)) {
                boolean dirExists = ftpClient.changeWorkingDirectory(subDirectory);
                if (!dirExists) {
                    logger.info("'{}' 폴더가 없어 새로 생성합니다.", subDirectory);
                    if (ftpClient.makeDirectory(subDirectory)) {
                        ftpClient.changeWorkingDirectory(subDirectory);
                    } else {
                        logger.error("'{}' 폴더 생성에 실패했습니다. FTP 사용자 권한을 확인하세요.", subDirectory);
                        return false;
                    }
                }
            }
            logger.info("최종 작업 디렉토리: {}", ftpClient.printWorkingDirectory());

            // 5. 파일을 실제로 업로드합니다.
            boolean done = ftpClient.storeFile(remoteFileName, fis);
            if (done) {
                logger.info("FTP 파일 업로드 성공: {}", remoteFileName);
            } else {
                logger.error("FTP 파일 업로드 실패: {}", remoteFileName);
            }
            return done;

        } catch (IOException e) {
            logger.error("FTP 업로드 작업 중 오류 발생", e);
            return false;
        } finally {
            // 6. 작업 완료 후 항상 연결을 안전하게 종료합니다.
            disconnect(ftpClient);
        }
    }

    @Override
    public byte[] downloadFile(String subDirectory, String fileName) throws IOException {
        FTPClient ftpClient = new FTPClient();
        try {
            ftpClient.connect(host, port);
            if (!ftpClient.login(username, password)) {
                throw new IOException("FTP 로그인 실패");
            }
            ftpClient.enterLocalPassiveMode();
            ftpClient.setFileType(FTP.BINARY_FILE_TYPE);

            // 기본 경로와 하위 폴더 경로를 조합하여 최종 파일 경로를 만듭니다.
            String remotePath = baseDirectory;
            if (StringUtils.hasText(subDirectory)) {
                remotePath += "/" + subDirectory;
            }
            String filePath = remotePath + "/" + fileName;
            
            // 파일을 메모리(ByteArrayOutputStream)에 직접 다운로드합니다.
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                boolean success = ftpClient.retrieveFile(filePath, outputStream);
                if (success) {
                    logger.info("FTP 파일 다운로드 성공: {}", filePath);
                    return outputStream.toByteArray();
                } else {
                    // 파일이 없거나 접근 권한이 없을 경우 예외를 발생시킵니다.
                    throw new IOException("FTP 파일 다운로드 실패: " + filePath);
                }
            }
        } catch (IOException e) {
            logger.error("FTP 다운로드 작업 중 오류 발생", e);
            throw e; // 예외를 다시 던져서 컨트롤러가 처리하도록 합니다.
        } finally {
            disconnect(ftpClient);
        }
    }
    
    @Override
    public boolean deleteFile(String subDirectory, String fileName) {
        // 파일 이름이나 하위 폴더 정보가 없으면, 삭제할 대상이 없으므로 작업을 건너뜁니다.
        if (!StringUtils.hasText(fileName) || !StringUtils.hasText(subDirectory)) {
            logger.warn("삭제할 파일 이름 또는 경로가 비어있어 FTP 파일 삭제를 건너뜁니다.");
            return true;
        }

        FTPClient ftpClient = new FTPClient();
        try {
            ftpClient.connect(host, port);
            if (!ftpClient.login(username, password)) {
                logger.error("FTP 로그인 실패 (파일 삭제 중)");
                return false; // 연결/로그인 실패는 명확한 실패로 처리합니다.
            }
            ftpClient.enterLocalPassiveMode();

            String remotePath = baseDirectory;
            if (StringUtils.hasText(subDirectory)) {
                remotePath += "/" + subDirectory;
            }
            String filePath = remotePath + "/" + fileName;
            
            // 실제 파일 삭제를 시도합니다.
            boolean deleted = ftpClient.deleteFile(filePath);
            
            if (deleted) {
                logger.info("FTP 파일 삭제 성공: {}", filePath);
            } else {
                // FTP 서버 응답 코드를 확인하여, 파일이 '원래 없었던' 것인지 확인합니다.
                int replyCode = ftpClient.getReplyCode();
                if (replyCode == 550) { // 550 응답 코드는 'File not found'를 의미합니다.
                    logger.warn("FTP 파일 삭제 시도: 파일이 이미 존재하지 않습니다. ({})", filePath);
                    return true; // 파일이 없어도 DB에서는 지워져야 하므로 성공으로 처리합니다.
                }
                logger.error("FTP 파일 삭제 실패: 응답코드={}, 경로={}", replyCode, filePath);
                return false; // 그 외의 실패는 명확한 실패로 처리합니다.
            }
            return true; 
        } catch (IOException e) {
            logger.error("FTP 파일 삭제 작업 중 IO 예외 발생", e);
            return false;
        } finally {
            disconnect(ftpClient);
        }
    }

    /**
     * FTP 연결을 안전하게 종료하는 헬퍼 메소드입니다.
     * 모든 FTP 작업 후에 호출되어 리소스 누수를 방지합니다.
     * @param ftpClient 연결을 종료할 FTPClient 객체
     */
    private void disconnect(FTPClient ftpClient) {
        if (ftpClient != null && ftpClient.isConnected()) {
            try {
                ftpClient.logout();
                ftpClient.disconnect();
                logger.info("FTP 서버 연결이 안전하게 종료되었습니다.");
            } catch (IOException ex) {
                logger.error("FTP 연결 종료 중 오류 발생", ex);
            }
        }
    }
}
